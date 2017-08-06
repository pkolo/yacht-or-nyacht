get '/personnel/:slug' do
  # Mock API call
  personnel = Personnel.find_by(slug: params[:slug]).serialize.to_json
  @personnel = JSON.parse(personnel)

  @subtitle = @personnel['name']
  @yachtski = @personnel['yachtski']
  @song_performances = @personnel['song_performances']
  @song_credits = @personnel['song_credits']
  @album_credits = @personnel['album_credits']
  @total_credits = @song_performances.length + @song_credits.length + @album_credits.length
  erb :'personnel/show'
end
