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
  @episode = Episode.find(params[:id])
  @songs = @episode.songs.sort_by { |song| song.yachtski }.reverse
  erb :'episodes/show'
end

get '/episodes/:id/edit' do
  if logged_in?
    @episode = Episode.find(params[:id])
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
  data = params[:song]
  @episode = Episode.find(params[:id])
  @artist = Artist.find_or_create_by(name: data[:artist])

  if @artist
    @song = Song.new(title: data[:title], year: data[:year], jd_score: data[:jd_score], hunter_score: data[:hunter_score], steve_score: data[:steve_score], dave_score: data[:dave_score])
    @song.artist = @artist
    @song.episode = @episode

    if @song.save
      erb :'/songs/_list_item', layout: false, locals: {song: @song}
    else
      "error"
    end
  end
end
