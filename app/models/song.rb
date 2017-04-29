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

  def self.dissent(host)
    host = host + "_score"
    other_hosts = ["jd_score", "hunter_score", "steve_score", "dave_score"] - [host]
    dissents = Song.all.map do |song|
      other_total = other_hosts.inject(0) {|sum, host_score| sum + song.send(host_score)}
      other_avg = other_total / other_hosts.length
      {song_id: song.id, dissent: (song.send(host) - other_avg)}
    end
    dissents.sort_by {|song| song[:dissent]}.reverse
  end

  def self.disagreement(host, other_host)
    host = host + "_score"
    other_host = other_host + "_score"
    disagreements = Song.all.map {|song| {song_id: song.id, disagreement: (song.send(host) - song.send(other_host))}}
    disagreements.sort_by {|song| song[:disagreement]}.reverse
  end

end
