get '/' do
  @songs = Song.all.sort_by {|song| song.yachtski}.reverse
  erb :'songs/index'
end

get '/songs/:id' do
  @song = Song.find(params[:id])
  erb :'songs/show'
end

get '/songs/:id/edit' do
  if logged_in?
    @song = Song.find(params[:id])
    erb :'songs/edit'
  else
    redirect '/'
  end
end

post '/songs/:id/discog_search' do
  if logged_in?
    @song = Song.find(params[:id])
    options = params[:options]
    if params[:discog] != ""
      url = "https://api.discogs.com/releases/" + params[:discog]
      @credits = @song.add_personnel(url, true)
      redirect to("/songs/#{params[:id]}")
    end

    @results = @song.discog_search(options).sort_by {|result| result["community"]["have"]}.reverse.first(20)
    if Album.match_in(@results)
      url = "https://api.discogs.com/releases/" + Album.match_in(@results).discog_id
      @credits = @song.add_personnel(url, false)
      redirect to("/songs/#{params[:id]}")
    else
      erb :'songs/_search_results', layout: false
    end
  else
    redirect '/'
  end
end

post '/songs/:id/add_personnel' do
  if logged_in?
    @song = Song.find(params[:id])
    @credits = @song.add_personnel(params[:url], true)
    redirect to("/songs/#{params[:id]}")
  else
    redirect '/'
  end
end

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end
