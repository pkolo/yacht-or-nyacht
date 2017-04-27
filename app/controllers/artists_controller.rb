get '/artists/:id' do
  @artist = Artist.find(params[:id])
  @songs = @artist.songs
  erb :'artists/show'
end
