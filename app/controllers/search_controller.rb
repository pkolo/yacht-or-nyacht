get '/search' do
  @q = params[:q]
  results = PgSearch.multisearch(@q)
  @song_results = results.where(searchable_type: "Song").map {|result| Song.find(result.searchable_id)}
  @album_results = results.where(searchable_type: "Album")
  @personnel_results = results.where(searchable_type: "Personnel")
  erb :'search/show'
end
