require 'json'

def cache_stats
  hosts = ["jd", "hunter", "steve", "dave"]
  hosts.each do |host|
    stats = host_stats_serializer(host)
    File.open("app/cache/#{host}.json","w+") do |f|
      f.write(stats.to_json)
    end
  end
end

def cache_index
  all_songs = Song.all.map {|song| song.to_json}
  File.open("app/cache/index.json","w+") do |f|
    f.write(all_songs.to_json)
  end
end
