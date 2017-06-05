get '/search' do
  @q = params[:q]
  @song_results = song_match(q)
  @personnel_results = personnel_match(q)
  erb :'search/show'
end
