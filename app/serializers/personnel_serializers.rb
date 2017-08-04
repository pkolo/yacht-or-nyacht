module PersonnelSerializers
  def serialize(args={})
    return self.link_serializer if args[:basic]

    {

    }
  end

  def link_serializer
    {
      id: self.id,
      name: self.name,
      resource_url: "/personnel/#{self.slug}",
      yachtski: self.yachtski
    }
  end

end
