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
