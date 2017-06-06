get '/albums/:slug' do
  @album = Album.find_by(slug: params[:slug])
  @subtitle = @album.title
  @songs = @album.songs.sort_by { |song| song.yachtski }.reverse
  erb :'albums/show'
end
