get '/' do
  @songs = Song.all
  erb :'songs/index'
end

get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'songs/stats'
end
