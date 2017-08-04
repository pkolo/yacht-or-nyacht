get '/albums/:slug' do
  album = Album.find_by(slug: params[:slug]).serialize({extended: true}).to_json
  @album = JSON.parse(album)
  @subtitle = @album['title']

  @songs = @album['tracklist'].sort_by { |song| song['scores']['yachtski'] }.reverse
  erb :'albums/show'
end
