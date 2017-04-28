class Song < ActiveRecord::Base
  belongs_to :episode
  belongs_to :artist

  def yachtski
    (self.dave_score + self.jd_score + self.hunter_score + self.steve_score) / 4.0
  end

  def host_deviations
    devs = {
      jd: (self.yachtski - self.jd_score).abs,
      hunter: (self.yachtski - self.hunter_score).abs,
      steve: (self.yachtski - self.steve_score).abs,
      dave: (self.yachtski - self.dave_score).abs
    }
  end

  # refactor this
  def self.avg_host_deviations
    total_songs = Song.all.length
    total_dev = self.all.inject({jd: 0, hunter: 0, steve: 0, dave: 0}) do |memo, song|
      devs = song.host_deviations
      memo[:jd] += devs[:jd]
      memo[:hunter] += devs[:hunter]
      memo[:steve] += devs[:steve]
      memo[:dave] += devs[:dave]
      memo
    end

    avg_dev = {
      jd: (total_dev[:jd] / total_songs),
      hunter: (total_dev[:hunter] / total_songs),
      steve: (total_dev[:steve] / total_songs),
      dave: (total_dev[:dave] / total_songs),
    }
    avg_dev
  end

end
