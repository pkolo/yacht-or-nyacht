require 'net/http'
require 'uri'
require 'json'

class Song < ActiveRecord::Base
  belongs_to :episode
  belongs_to :album

  has_many :credits, as: :creditable, dependent: :destroy do
    def players
      where("role != ?", "Artist")
    end
  end

  has_many :performers, ->(credit) { where 'credits.role = ?', "Artist" }, through: :credits, source: :personnel
  after_create :create_slug

  def artist
    self.performers.pluck(:name).first
  end

  def artist_list
    artist_data = self.performers.pluck(:slug, :name)
    artist_data.map { |data| "<a href='/personnel/#{data[0]}'>#{data[1]}</a>"}.join(", ")
  end

  def combined_players
    roles = self.credits.players.pluck(:role).uniq
    roles.each_with_object([]) do |role, memo|
      credits = self.credits.players.where(role: role)

      players = {
        role: role,
        personnel: credits.map { |credit| "<a href='/personnel/#{credit.personnel.slug}'>#{credit.personnel.name}</a>" }
      }
      memo << players
    end
  end

  def personnel_combined_roles
    # Combine players by name, combine their roles
    personnel = self.credits.players.each_with_object([]) do |credit, memo|
      combined_roles = {
        personnel: credit.personnel,
        roles: self.credits.players.where(personnel_id: credit.personnel.id).pluck(:role)
      }
      memo << combined_roles
    end
    personnel.uniq
  end

  def nice_title
    "#{self.artist_list} - #{self.title} (#{self.year})"
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

  def build_query(options)
    q = "type=release&token=#{ENV['DISCOG_TOKEN']}"

    if options.include?("artist")
      q += "&artist=#{self.artist.gsub(/[^0-9a-z ]/i, '')}"
    end

    if options.include?("title")
      q += "&track=#{self.title}"
    end

    if options.include?("year")
      q += "&year=#{self.year}"
    end

    q
  end

  def discog_search(options)
    q = self.build_query(options)
    url = "https://api.discogs.com/database/search?#{q}"
    response = api_call(url)
    response["results"]
  end

  def add_personnel(url, add_album_personnel)
    results = api_call(url)
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
    track_personnel = other_personnel.select {|person| includes_track?(all_tracks, person, self.track_no)}
    track_personnel += track_data["extraartists"] if track_data["extraartists"]

    track_personnel.each do |personnel|
      new_person = Personnel.find_or_create_by(name: remove_parens(personnel["name"]), discog_id: personnel["id"])
      personnel["role"].split(", ").each do |role|
        if role.include?("Duet")
          credit = Credit.new(role: "Artist", personnel: new_person)
        elsif role.include?("Featuring")
          credit = Credit.new(role: "Artist", personnel: new_person)
        else
          credit = Credit.new(role: role, personnel: new_person)
        end
        self.credits << credit
      end
    end
    self.credits
  end

  def api_call(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    result = JSON.parse(response.body)
  end

  def self.essentials
    self.all.select {|song| song.yachtski >= 90 }
  end

  def self.title_search(query)
    self.where("similarity(title, ?) > 0.3", query).order("similarity(title, #{ActiveRecord::Base.connection.quote(query)}) DESC")
  end

  private
    def create_slug
      self.slug = sluggify(self.title, self.id)
      self.save
    end

end
