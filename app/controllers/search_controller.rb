get '/search' do
  @q = params[:q]
  @song_results = Song.title_search(@q)
  @personnel_results = Personnel.name_search(@q)
  erb :'search/show'
end
