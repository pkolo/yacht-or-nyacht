module AlbumSerializers

  def serialize(args={})
    serialized_album = {
      artists: self.serialize_credits(self.credits.artist_credits),
      title: self.title,
      year: self.year,
      yachtski: self.yachtski,
      resource_url: "/albums/#{self.slug}",
    }

    if args[:basic]
      serialized_album[:personnel] = self.serialize_credits_from_sql(self.players)
    end

    if args[:extended]
      serialized_album[:yachtski] = self.yachtski
      serialized_album[:tracklist] = self.songs.map {|song| song.serialize}
      serialized_album[:personnel] = self.serialize_credits_from_sql(self.players)
    end

    serialized_album
  end

end
