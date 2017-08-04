module PersonnelSerializers
  def serialize(args={})
    return self.link_serializer if args[:basic]

    serialized_personnel = self.link_serializer
    serialized_personnel[:song_performances] = self.song_performances.map {|song| song.serialize }
    serialized_personnel[:song_credits] = self.serialize_song_credits
    serialized_personnel[:album_credits] = self.serialize_album_credits

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

  def serialize_song_credits
    combined_credits = self.song_credits.uniq.each_with_object([]) do |credit, memo|
      combined_credit = {
        media: credit.creditable.serialize,
        roles: self.song_credits.where(creditable_id: credit.creditable.id).pluck(:role)
      }
      memo << combined_credit
    end
    combined_credits.uniq {|c| c[:media]}
  end

  def serialize_album_credits
    combined_credits = self.album_credits.each_with_object([]) do |credit, memo|
      combined_credit = {
        media: credit.creditable.serialize,
        roles: self.album_credits.where(creditable_id: credit.creditable.id).pluck(:role)
      }
      memo << combined_credit
    end
    combined_credits.uniq {|c| c[:media]}
  end

end
