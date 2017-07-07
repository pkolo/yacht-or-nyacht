require 'json'

def cache_index
  all_songs = Song.all.map {|song| song.serialize}
  File.open("app/cache/index.json","w+") do |f|
    f.write(all_songs.to_json)
  end
end
