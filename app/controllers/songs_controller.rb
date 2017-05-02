get '/' do
  @songs = Song.all
  erb :'songs/index'
end

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end

get '/songs/:id' do
  @song = Song.find(params[:id])
  erb :'songs/show'
end

get '/songs/:id/edit' do
  @song = Song.find(params[:id])
  erb :'songs/edit'
end

get '/songs/:id/discog_search' do
  @song = Song.find(params[:id])
  @response = @song.discog_search
  @results = @response["results"].sort_by {|result| result["community"]["have"]}.reverse.first(10)
  binding.pry
  erb :'songs/_search_results', layout: false
end

# post '/songs/:id/add_personnel' do
#   render "test"
# end
