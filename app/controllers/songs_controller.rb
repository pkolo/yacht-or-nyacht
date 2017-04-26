get '/songs/' do
  @songs = Song.all
  component = react_component('Hello', prerender: true)
  erb :'songs/index'
end
