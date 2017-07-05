get '/stats' do
  @hosts = ["jd", "hunter", "steve", "dave"]
  erb :'stats/_hosts'
end
