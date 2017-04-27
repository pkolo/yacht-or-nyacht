get '/artists/:id' do
  @artist = Artist.find(params[:id])
  erb :'artists/show'
end
