module PersonnelHelper

  def build_list(result, title)
    # Pulls track-specific data from result
    track_data = result["tracklist"].find {|track| is_match?(remove_parens(track["title"]), remove_parens(title)) }
    track_no = track_data["position"]
    title = track_data["title"]

    # Isolates album-only credits and adds them to output hash
    album_credits = result["extraartists"].select{|artist| artist["tracks"] == "" }
    album_personnel = album_credits.inject([]) do |memo, credit|
      if Personnel.find_by(discog_id: credit["id"])
        person = Personnel.find_by(discog_id: credit["id"])
        memo << {name: person.name, role: credit["role"], slug: person.slug, yachtski: person.yachtski}
      else
        memo << {name: credit["name"], role: credit["role"], yachtski: -1}
      end
    end

    other_credits = result["extraartists"] - album_credits # Isolates track-specific credits from general album credits
    all_tracks = result["tracklist"].map {|track| track["position"]} # Creates an array of track positions
    track_credits = other_credits.select {|credit| credit_in_track_range?(all_tracks, credit, track_no)} # Finds single-song credits within a range
    track_credits += track_data["extraartists"] if track_data["extraartists"]

    track_personnel = track_credits.inject([]) do |memo, credit|
      if Personnel.find_by(discog_id: credit["id"])
        person = Personnel.find_by(discog_id: credit["id"])
        memo << {name: person.name, role: credit["role"], slug: person.slug, yachtski: person.yachtski}
      else
        memo << {name: credit["name"], role: credit["role"], yachtski: -1}
      end
    end

    {
      album_personnel: album_personnel,
      track_personnel: track_personnel
    }

  end

  def credit_in_track_range?(all_tracks, person, track_no)
    extract_range = person["tracks"].split(", ").map do |track|
      if track.include?("to")
        range = track.split(" to ")
        start = all_tracks.index(range[0])
        fin = all_tracks.index(range[1])
        all_tracks[start..fin]
      elsif track.include?("-")
        range = track.split("-")
        start = all_tracks.index(range[0])
        fin = all_tracks.index(range[1])
        all_tracks[start..fin]
      else
        track
      end
    end
    extract_range.flatten.include?(track_no)
  end

end
