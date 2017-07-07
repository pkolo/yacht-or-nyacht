require 'json'

get '/stats' do
  host = ["jd", "steve", "hunter", "dave"].sample
  cache = File.read("app/cache/#{host}.json")
  @stats = JSON.parse(cache)
  erb :'stats/_hosts'
end

get '/stats/:host' do
  cache = File.read("app/cache/#{params[:host]}.json")
  @stats = JSON.parse(cache)
  if @stats
    erb :'stats/_hosts'
  else
    redirect '/'
  end
end
