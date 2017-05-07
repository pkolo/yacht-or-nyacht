get '/albums/:id' do
  @album = Album.find(params[:id])
  @songs = @album.songs.sort_by { |song| song.yachtski }.reverse
  erb :'albums/show'
end
