get '/search' do
  @q = params[:q]
  binding.pry
  erb :'search/show'
end
