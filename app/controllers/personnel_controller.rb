get '/personnel/:id' do
  @personnel = Personnel.find(params[:id])
  @song_credits = @personnel.credits.where(creditable_type: "Song")
  @album_credits = @personnel.credits.where(creditable_type: "Album")
  erb :'personnel/show'
end
