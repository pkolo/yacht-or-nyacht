module EpisodeSerializers
  def serialize
    {
      id: self.id,
      number: self.number,
      resource_url: "/episodes/#{self.id}",
      title: self.title,
      podcast_url: self.link,
      tracklist: self.songs.map {|song| song.serialize }
    }
  end
end
