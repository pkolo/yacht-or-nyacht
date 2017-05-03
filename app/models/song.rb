require 'net/http'
require 'uri'
require 'json'

class Song < ActiveRecord::Base
  belongs_to :episode
  belongs_to :artist
  belongs_to :album

  has_many :credits, as: :creditable

  def nice_title
    "#{self.artist.name} - #{self.title} (#{self.year})"
  end

  def yachtski
    (self.dave_score + self.jd_score + self.hunter_score + self.steve_score) / 4.0
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

  def discog_search
    q = "type=release&track=#{self.title}&artist=#{self.artist.name}&year=#{self.year}&token=#{ENV['DISCOG_TOKEN']}"
    url = "https://api.discogs.com/database/search?#{q}"
    api_call(url)
  end

  def add_personnel(url)
    results = api_call(url)

    album = Album.find_or_create_by(title: results["title"], discog_id: results["id"])
    self.album = album
    track_data = results["tracklist"].find {|track| track["title"] == self.title }
    self.track_no = track_data["position"]

    album_personnel = results["extraartists"].select{|artist| artist["tracks"] == "" }
    album_personnel.each do |personnel|
      new_person = Personnel.find_or_create_by(name: personnel["name"], discog_id: personnel["id"])
      personnel["role"].split(", ").each do |role|
        credit = Credit.new(role: role, personnel: new_person)
        album.credits << credit
      end
    end

  end

  def api_call(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    result = JSON.parse(response.body)
  end

  def self.essentials
    self.all.select {|song| song.yachtski >= 90 }
  end

end
