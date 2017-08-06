get '/episodes/new' do
  if logged_in?
    @recent_episode = Episode.all.last
    erb :'episodes/new'
  else
    redirect '/'
  end
end

post '/episodes' do
  if logged_in?
    @episode = Episode.new(number: params[:episode][:number])
    if @episode.save
      redirect to "/episodes/#{@episode.id}"
    else
      @recent_episode = Episode.all.last
      erb :'episodes/new'
    end
  else
    redirect '/'
  end
end

get '/episodes/:id' do
  episode = Episode.find(params[:id]).serialize.to_json
  @episode = JSON.parse(episode)

  @songs = @episode['tracklist']
  erb :'episodes/show'
end

get '/episodes/:id/edit' do
  if logged_in?
    episode = Episode.find(params[:id]).serialize.to_json
    @episode = JSON.parse(episode)

    @songs = @episode['tracklist']
    erb :'episodes/edit'
  else
    redirect '/'
  end
end

get '/episodes/:id/songs/new' do
  if logged_in?
    @episode = Episode.find(params[:id])
    erb :'/songs/_form', layout: false
  else
    redirect '/'
  end
end

post '/episodes/:id/songs' do
  if logged_in?
    data = params[:song]
    @episode = Episode.find(params[:id])
    @artist = Personnel.find_by("similarity(name, ?) > 0.5", data[:artist])
    @song = Song.new(title: data[:title], year: data[:year], jd_score: data[:jd_score], hunter_score: data[:hunter_score], steve_score: data[:steve_score], dave_score: data[:dave_score])
    @song.episode = @episode

    if @artist
      @song.credits.build(personnel: @artist, role: "Artist")
    else
      @artist = Personnel.create(name: data[:artist])
      @song.credits.build(personnel: @artist, role: "Artist")
    end

    if @song.save
      erb :'/episodes/_list_item', layout: false, locals: {song: @song}
    else
      "error"
    end

  else
    redirect '/'
  end
end
