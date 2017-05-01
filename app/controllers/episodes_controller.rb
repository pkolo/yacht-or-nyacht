get '/episodes/new' do
  @recent_episode = Episode.all.last
  erb :'episodes/new'
end
