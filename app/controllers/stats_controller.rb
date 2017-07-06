get '/stats' do
  host = ["jd", "hunter", "steve", "dave"].sample
  @stats = host_stats_serializer(host)
  erb :'stats/_hosts'
end

get '/stats/:host' do
  @stats = host_stats_serializer(params[:host])
  if @stats
    erb :'stats/_hosts'
  else
    redirect '/'
  end
end
