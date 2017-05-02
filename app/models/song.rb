require 'net/http'
require 'uri'
require 'json'

class Song < ActiveRecord::Base
  belongs_to :episode
  belongs_to :artist

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
    q = "track=#{self.title}&artist=#{self.artist.name}&year=#{self.year}&token=#{ENV['DISCOG_TOKEN']}"
    url = "https://api.discogs.com/database/search?#{q}"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end

  def self.essentials
    self.all.select {|song| song.yachtski >= 90 }
  end

end
