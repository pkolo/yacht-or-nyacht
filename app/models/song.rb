class Song < ActiveRecord::Base
  belongs_to :episode
  belongs_to :artist

  def yachtski
    (self.dave_score + self.jd_score + self.hunter_score + self.steve_score) / 4.0
  end

  def host_deviations
    devs = {
      jd_deviation: (self.yachtski - self.jd_score).abs,
      hunter_deviation: (self.yachtski - self.hunter_score).abs,
      steve_deviation: (self.yachtski - self.steve_score).abs,
      dave_deviation: (self.yachtski - self.dave_score).abs
    }
  end
end
