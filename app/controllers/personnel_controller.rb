get '/personnel/:slug' do
  @personnel = Personnel.find_by(slug: params[:slug])
  @yachtski = @personnel.yachtski
  @song_performances = @personnel.song_performances.sort_by {|song| song.yachtski }.reverse
  @song_credits = @personnel.combined_song_credits.sort_by { |credit| credit[:yachtski] }.reverse
  @album_credits = @personnel.combined_album_credits.sort_by { |credit| credit[:yachtski] }.reverse
  erb :'personnel/show'
end
