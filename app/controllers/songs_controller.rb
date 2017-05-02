get '/' do
  @songs = Song.all
  erb :'songs/index'
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
  @results = @song.discog_search["results"].sort_by {|result| result["community"]["have"]}.reverse.first(10)
  erb :'songs/_search_results', layout: false
end

post '/songs/:id/add_personnel' do
  "test"
end

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end
