module AlbumSerializers

  def serialize(args={})
    serialized_album = {
      artists: self.serialize_credits(self.credits.artist_credits),
      title: self.title,
      year: self.year,
      resource_url: "/albums/#{self.slug}",
      personnel: self.serialize_credits(self.credits.player_credits)
    }

    if args[:extended]
      serialized_album[:yachtski] = self.yachtski
      serialized_album[:tracklist] = self.songs.map {|song| song.serialize}
    end

    serialized_album
  end

end
