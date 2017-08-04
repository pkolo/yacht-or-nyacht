module SongSerializers

  # Creates a hash of song data, used by cache for song show page
  # Takes args :extended for full player credits
  def serialize(args={})
    serialized_song = {
      id: self.id,
      resource_url: "/songs/#{self.slug}",
      title: self.title,
      year: self.year,
      status: self.status,
      video_url: "https://www.youtube.com/embed/#{self.yt_id}",
      scores: {
        jd: self.jd_score,
        hunter: self.hunter_score,
        steve: self.steve_score,
        dave: self.dave_score,
        yachtski: self.yachtski
      },
      episode: {
        number: self.episode.number,
        resource_url: "/episodes/#{self.episode.id}"
      },
      personnel: {
        artists: self.serialize_credits(self.credits.artist_credits)
      }
    }

    serialized_song[:personnel][:features] = self.serialize_credits(self.credits.feature_credits) if self.serialize_credits(self.credits.feature_credits).any?
    serialized_song[:personnel][:players] = self.serialize_credits(self.credits.player_credits) if args[:extended]

    serialized_song
  end
end
