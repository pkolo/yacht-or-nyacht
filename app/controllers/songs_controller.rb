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
  if Album.match_in(@results)
    url = "https://api.discogs.com/releases/" + Album.match_in(@results)
    @credits = @song.add_personnel(url)
    erb :'songs/_personnel', layout: false, locals: {credits: @credits}
  else
    erb :'songs/_search_results', layout: false
  end
end

post '/songs/:id/add_personnel' do
  @song = Song.find(params[:id])
  @credits = @song.add_personnel(params[:url])
  erb :'songs/_personnel', layout: false, locals: {credits: @credits}
end

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end
