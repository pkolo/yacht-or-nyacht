require_relative '../helpers/discog_helper'

include DiscogHelper

get '/' do
  cache = File.read("app/cache/index.json")
  res = JSON.parse(cache)
  @songs = res.sort_by {|song| song['scores']['yachtski']}.reverse
  erb :'songs/index'
end

get '/songs/:slug' do
  @song = Song.find_by(slug: params[:slug])
  @subtitle = @song.title
  erb :'songs/show'
end

get '/songs/:slug/edit' do
  if logged_in?
    @song = Song.find_by(slug: params[:slug])
    erb :'songs/edit'
  else
    redirect '/'
  end
end

post '/songs/:slug/discog_search' do
  if logged_in?
    @song = Song.find_by(slug: params[:slug])
    options = params[:options]
    if params[:discog] != ""
      url = "https://api.discogs.com/releases/" + params[:discog]
      @credits = @song.add_personnel(url, true)
      redirect to("/songs/#{params[:slug]}")
    end

    @results = DiscogHelper.search(options).sort_by {|result| result["community"]["have"]}.reverse.first(20)
    if Album.match_in(@results)
      url = "https://api.discogs.com/releases/" + Album.match_in(@results).discog_id
      @credits = @song.add_personnel(url, false)
      redirect to("/songs/#{params[:slug]}")
    else
      erb :'songs/_search_results', layout: false
    end
  else
    redirect '/'
  end
end

post '/songs/:slug/add_personnel' do
  if logged_in?
    @song = Song.find_by(slug: params[:slug])
    @credits = @song.add_personnel(params[:url], true)
    redirect to("/songs/#{@song.slug}")
  else
    redirect '/'
  end
end
