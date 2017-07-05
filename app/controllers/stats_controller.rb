get '/stats' do
  @stats = host_stats_serializer
  erb :'stats/_hosts'
end

get '/host_stats' do
  @data = host_stats_serializer.first
  @data.to_json
end
