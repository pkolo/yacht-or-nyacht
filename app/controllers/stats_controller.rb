get '/stats' do
  @hosts = ["jd"]
  erb :'stats/_hosts'
end
