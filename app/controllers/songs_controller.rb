get '/' do
  @songs = Song.all
  erb :'songs/index'
end

get '/songs/:id' do
  @song = Song.find(params[:id])
  erb :'songs/show'
end

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end
