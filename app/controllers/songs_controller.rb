require_relative '../helpers/discog_helpers'
require_relative '../helpers/personnel_helpers'
require 'json'

include DiscogHelpers
include PersonnelHelpers

get '/' do
  cache = File.read("app/cache/index.json")
  res = JSON.parse(cache)
  @songs = res.sort_by {|song| song['yachtski']}.reverse
  erb :'songs/index'
end

get '/personnel-checker' do
  if request.xhr?
    search_options = {artist: params[:artist], title: params[:title], year: params[:year]}
    @results = DiscogHelpers.credits_quality(search_options)
    if @results.any?
      @main_result = @results.first[:result]
      @main_result_details = PersonnelHelpers.build_list(@main_result, params[:title])
      content_type :json
      {status: 'success', content: (erb :'songs/_song_checker_results', layout: false)}.to_json
    else
      content_type :json
      {status: 'error', message: 'There are no matching results. Make sure you have the correct information.'}.to_json
    end
  else
    erb :'songs/search'
  end
end

get '/songs/:slug' do
  # This is redundant, meant to mimic API call
  song = Song.find_by(slug: params[:slug]).serialize({extended: true}).to_json
  @song = JSON.parse(song)
  @episode = @song['episode']
  @album = @song['album']
  @scores = @song['scores']
  @personnel = @song['personnel']
  @subtitle = @song['title']
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

    @results = DiscogHelpers.search(options, @song).sort_by {|result| result["community"]["have"]}.reverse.first(20)
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
