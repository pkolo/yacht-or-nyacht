module AlbumSerializers

  def serialize(args={})
    serialized_album = {
      title: self.title,
      resource_url: "/albums/#{self.slug}",
      personnel: self.serialize_credits(self.credits.player_credits)
    }
  end

end
