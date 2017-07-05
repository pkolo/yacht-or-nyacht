def host_stats_serializer
  hosts = ["jd", "hunter", "steve", "dave"]
  host_stats = hosts.inject([]) do |memo, host|
    stats = {
      host: nice_name(host),
      yacht_count: yacht_count(host),
      avg_deviation_from_mean: avg_deviation(host),
      dissents: dissents(host)
    }
    memo << stats
  end
end

def get_column(host)
  host + "_score"
end

def get_other_hosts(host)
  other_hosts = ["jd_score", "hunter_score", "steve_score", "dave_score"] - [get_column(host)]
end

def nice_name(host)

  if host == "jd"
    "JD Ryznar"
  elsif host == "hunter"
    "Hunter Stair"
  elsif host == "steve"
    "Steve Huey"
  elsif host == "dave"
    "Dave Lyons"
  end

end

def yacht_count(host)
  total_essential = Song.where("#{get_column(host)} >= ?", 90).length
  total_yacht = Song.where("#{get_column(host)} >= ? AND #{get_column(host)} < ?", 50, 90).length
  total_nyacht = Song.where("#{get_column(host)} < ?", 50).length
  {essential: total_essential, yacht: total_yacht, nyacht: total_nyacht}
end

def avg_deviation(host)
  avg_host_deviations[host.to_sym]
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
    "jd": (total_dev[:jd] / total_songs),
    "hunter": (total_dev[:hunter] / total_songs),
    "steve": (total_dev[:steve] / total_songs),
    "dave": (total_dev[:dave] / total_songs),
  }
  avg_dev
end

def dissents(host)
  other_hosts = get_other_hosts(host)
  host = get_column(host)

  dissents = Song.all.map do |song|
    other_total = other_hosts.inject(0) {|sum, other_host_score| sum + song.send(other_host_score)}
    other_avg = other_total / other_hosts.length
    {song: song, host_score: song.send(host), avg_without_host: other_avg, dissent: (song.send(host) - other_avg)}
  end

  dissents.sort_by! {|song| song[:dissent]}.reverse
  {nyacht: dissents.first(3), yacht: dissents.last(3).reverse}
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

def weird_essentials(host)
  host_score = get_column(host)
  Song.where("#{host_score} >= 90") - Song.essentials
end
