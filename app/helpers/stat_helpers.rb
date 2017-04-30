def get_column(host)
  host + "_score"
end

def get_other_hosts(host)
  other_hosts = ["jd_score", "hunter_score", "steve_score", "dave_score"] - [get_column(host)]
end

def total_yacht_pct(host)
  total_yacht = Song.where("#{get_column(host)} >= ?", 50).length
  {total_yacht: total_yacht, yacht_pct: (total_yacht / Song.all.length.to_f)}
end

def avg_host_deviations
  total_songs = Song.all.length
  total_dev = Song.all.inject({jd: 0, hunter: 0, steve: 0, dave: 0}) do |memo, song|
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

def dissent(host)
  other_hosts = get_other_hosts(host)
  host = get_column(host)

  dissents = Song.all.map do |song|
    other_total = other_hosts.inject(0) {|sum, other_host_score| sum + song.send(other_host_score)}
    other_avg = other_total / other_hosts.length
    {song: song, dissent: (song.send(host) - other_avg)}
  end

  dissents.sort_by {|song| song[:dissent]}.reverse
end

def all_disagreements(host)
  other_hosts = get_other_hosts(host)
  host = get_column(host)
  other_hosts.inject([]) do |memo, other_host|
    disagreements = disagreement(host, other_host)
    memo <<
      {
        host: other_host[0..-7],
        yacht: disagreements.first,
        nyacht: disagreements.last
      }
  end
end

# takes column names
def disagreement(host, other_host)
  disagreements = Song.all.map {|song| {song: song, disagreement: (song.send(host) - song.send(other_host))}}
  disagreements.sort_by {|song| song[:disagreement]}.reverse
end
