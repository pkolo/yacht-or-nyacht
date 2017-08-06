module PersonnelSerializers
  def serialize(args={})
    return self.link_serializer if args[:basic]

    serialized_personnel = self.link_serializer
    serialized_personnel[:song_performances] = self.song_performances.map {|song| song.serialize }
    serialized_personnel[:song_credits] = self.serialize_personnel_credits_from_sql(self.credits_for("songs"))
    serialized_personnel[:album_credits] = self.serialize_personnel_credits_from_sql(self.credits_for("albums"))

    serialized_personnel
  end

  def link_serializer
    {
      id: self.id,
      name: self.name,
      resource_url: "/personnel/#{self.slug}",
      yachtski: self.yachtski
    }
  end

  def serialize_personnel_credits_from_sql(credits_list)
    credits_list.map do |credit|
      {
        media: credit["type"].constantize.find(credit["id"]).serialize,
        roles: credit["roles"].split(', ')
      }
    end
  end

end
