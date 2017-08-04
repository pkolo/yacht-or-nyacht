require 'net/http'
require 'uri'
require 'json'
require_relative '../helpers/discog_helpers'
require_relative '../helpers/personnel_helpers'
require_relative '../helpers/creditable_helpers'

class Song < ActiveRecord::Base
  include DiscogHelpers
  include PersonnelHelpers
  include CreditableHelpers

  belongs_to :episode
  belongs_to :album

  has_many :credits, as: :creditable, dependent: :destroy do
    def player_credits
      where("role NOT IN (?)", ["Artist", "Duet", "Featuring"])
    end

    def artist_credits
      where 'role IN (?)', ["Artist"]
    end

    def feature_credits
      where 'role IN (?)', ["Duet", "Featuring"]
    end
  end

  has_many :players, ->(credit) { where("credits.role NOT IN (?)", ["Artist", "Duet", "Featuring"]) }, through: :credits, source: :personnel
  has_many :performers, ->(credit) { where 'credits.role IN (?)', ["Artist"] }, through: :credits, source: :personnel
  has_many :features, ->(credit) { where 'credits.role IN (?)', ["Duet", "Featuring"] }, through: :credits, source: :personnel
  after_create :create_slug
  after_create :get_youtube_id

  # Creates a hash of song data, used by cache for index page
  def to_json
    {
      slug: self.slug,
      title: self.title,
      year: self.year,
      artists: self.artist_json,
      features: self.feature_json,
      scores: {
        jd: self.jd_score,
        hunter: self.hunter_score,
        steve: self.steve_score,
        dave: self.dave_score,
        yachtski: self.yachtski
      },
      episode: {
        id: self.episode.id,
        number: self.episode.number
      },
      personnel: {
        artists: self.serialize_credits(self.credits.artist_credits),
        features: self.serialize_credits(self.credits.feature_credits),
        players: self.serialize_credits(self.credits.player_credits)
      }
    }
  end

  def artist
    self.performers.pluck(:name).first
  end

  def artist_list
    artist_data = self.performers.pluck(:slug, :name)
    artists = artist_data.map { |data| "<a href='/personnel/#{data[0]}'>#{data[1]}</a>"}.join(", ")
    if self.features.any?
      feature_data = self.features.pluck(:slug, :name)
      features = feature_data.map {|data| "<a href='/personnel/#{data[0]}'>#{data[1]}</a>"}.join(", ")
      [artists, features].join(" w/ ")
    else
      artists
    end
  end

  def artist_json
    artist_data = self.performers.pluck(:slug, :name)
    artists = artist_data.map { |data| {slug: data[0], name: data[1]} }
  end

  def feature_json
    feature_data = self.features.pluck(:slug, :name)
    features = feature_data.map { |data| {slug: data[0], name: data[1]} }
  end

  def yachtski
    (self.dave_score + self.jd_score + self.hunter_score + self.steve_score) / 4.0
  end

  def status
    if self.essential?
      "Essential Yacht"
    elsif self.yachtski >= 50
      "Yacht"
    else
      "Nyacht"
    end
  end

  def essential?
    self.yachtski >= 90
  end

  def host_deviations
    devs = {
      jd: (self.yachtski - self.jd_score).abs,
      hunter: (self.yachtski - self.hunter_score).abs,
      steve: (self.yachtski - self.steve_score).abs,
      dave: (self.yachtski - self.dave_score).abs
    }
  end

  def add_personnel(url, add_album_personnel)
    results = DiscogHelpers.api_call(url)
    album = Album.find_or_create_by(year: results["year"], title: results["title"], discog_id: results["id"])
    self.album = album
    track_data = results["tracklist"].find {|track| is_match?(remove_parens(track["title"]), remove_parens(self.title)) }
    self.track_no = track_data["position"]
    self.title = track_data["title"]
    self.credits.delete_all
    self.slug = sluggify(track_data["title"], self.id)
    self.save

    if track_data["artists"]
      track_data["artists"].each do |artist|
        new_person = Personnel.find_or_create_by(name: remove_parens(artist["name"]), discog_id: artist["id"])
        song_credit = Credit.new(role: "Artist", personnel: new_person)
        self.credits << song_credit
      end

      if add_album_personnel
        results["artists"].each do |artist|
          new_person = Personnel.find_or_create_by(name: remove_parens(artist["name"]), discog_id: artist["id"])
          album_credit = Credit.new(role: "Artist", personnel: new_person)
          album.credits << album_credit
        end
      end
    else
      results["artists"].each do |artist|
        new_person = Personnel.find_or_create_by(name: remove_parens(artist["name"]), discog_id: artist["id"])
        song_credit = Credit.new(role: "Artist", personnel: new_person)
        self.credits << song_credit
        if add_album_personnel
          album_credit = Credit.new(role: "Artist", personnel: new_person)
          album.credits << album_credit
        end
      end
    end

    album_personnel = results["extraartists"].select{|artist| artist["tracks"] == "" }

    if add_album_personnel
      album_personnel.each do |personnel|
        new_person = Personnel.find_or_create_by(name: remove_parens(personnel["name"]), discog_id: personnel["id"])
        personnel["role"].split(", ").each do |role|
          credit = Credit.new(role: role, personnel: new_person)
          album.credits << credit
        end
      end
    end

    other_personnel = results["extraartists"] - album_personnel
    all_tracks = results["tracklist"].map {|track| track["position"]}
    track_personnel = other_personnel.select {|person| PersonnelHelpers.credit_in_track_range?(all_tracks, person, self.track_no)}
    track_personnel += track_data["extraartists"] if track_data["extraartists"]

    track_personnel.each do |personnel|
      new_person = Personnel.find_or_create_by(name: remove_parens(personnel["name"]), discog_id: personnel["id"])
      personnel["role"].split(", ").each do |role|
        if role.include?("Duet")
          credit = Credit.new(role: "Duet", personnel: new_person)
        elsif role.include?("Featuring")
          credit = Credit.new(role: "Featuring", personnel: new_person)
        else
          credit = Credit.new(role: role, personnel: new_person)
        end
        self.credits << credit
      end
    end
    self.credits
  end

  def self.essentials
    self.all.select {|song| song.yachtski >= 90 }
  end

  def self.title_search(query)
    self.where("similarity(title, ?) > 0.3", query).order("similarity(title, #{ActiveRecord::Base.connection.quote(query)}) DESC")
  end

  def get_youtube_id
    base = "https://www.googleapis.com/youtube/v3/search?"
    q = "part=snippet&type=video&videoEmbeddable=true&q=#{self.artist.downcase.gsub(/[^0-9a-z ]/i, '')} #{self.title.downcase.gsub(/[^0-9a-z ]/i, '')}&key=#{ENV['YT_KEY']}"
    res = api_call(base+q)
    vid_data = res["items"].first
    vid_id = vid_data["id"]["videoId"]
    self.yt_id = vid_id
    self.save
  end

  def self.youtube_writer
    self.all.each { |song| song.get_youtube_id }
  end

  private
    def create_slug
      self.slug = sluggify(self.title, self.id)
      self.save
    end

end
