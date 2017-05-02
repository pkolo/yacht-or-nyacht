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

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end
