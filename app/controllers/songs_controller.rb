get '/' do
  @songs = Song.all
  erb :'songs/index'
end

get '/stats' do
  erb :'songs/stats'
end
