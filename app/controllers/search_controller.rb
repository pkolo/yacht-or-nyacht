get '/search' do
  @q = params[:q]
  @personnel_results = Personnel.name_search(@q)
  erb :'search/show'
end
