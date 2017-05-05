get '/albums/:id' do
  @album = Album.find(params[:id])
  erb :'albums/show'
end
