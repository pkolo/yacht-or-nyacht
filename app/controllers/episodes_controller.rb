get '/episodes/new' do
  @recent_episode = Episode.all.last
  erb :'episodes/new'
end

post '/episodes' do
  @episode = Episode.new(number: params[:episode][:number])
  if @episode.save
    redirect to "/episodes/#{@episode.id}"
  else
    @recent_episode = Episode.all.last
    erb :'episodes/new'
  end
end

get '/episodes/:id' do
  @episode = Episode.find(params[:id])
  erb :'episodes/show'
end

get '/episodes/:id/edit' do
  @episode = Episode.find(params[:id])
  erb :'episodes/edit'
end

get '/episodes/:id/songs/new' do
  @episode = Episode.find(params[:id])
  erb :'/songs/_form', layout: false
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
