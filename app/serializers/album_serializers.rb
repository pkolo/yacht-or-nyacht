module AlbumSerializers

  def serialize(args={})
    serialized_album = {
      title: self.title,
      resource_url: "/albums/#{self.slug}"
    }
  end

end
