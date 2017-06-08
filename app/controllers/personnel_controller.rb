get '/personnel/:slug' do
  @personnel = Personnel.find_by(slug: params[:slug])
  @subtitle = @personnel.name
  @yachtski = @personnel.yachtski
  @song_performances = @personnel.song_performances.sort_by {|song| song.yachtski }.reverse
  @song_credits = @personnel.combined_song_credits.sort_by { |credit| credit[:media].yachtski }.reverse
  @album_credits = @personnel.combined_album_credits.sort_by { |credit| credit[:media].yachtski }.reverse
  erb :'personnel/show'
end
