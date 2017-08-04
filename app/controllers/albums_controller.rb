get '/albums/:slug' do
  album = Album.find_by(slug: params[:slug]).serialize.to_json
  @album = JSON.parse(album)
  binding.pry
  @subtitle = @album.title
  @songs = @album.songs.sort_by { |song| song.yachtski }.reverse
  erb :'albums/show'
end
