module PersonnelHelper

  def build_list(result, title)
    album_personnel = result["extraartists"].inject([]) do |memo, credit|
      if Personnel.find_by(discog_id: credit["id"])
        person = Personnel.find_by(discog_id: credit["id"])
        memo << {name: person.name, role: credit["role"], id: person.id, yachtski: person.yachtski}
      else
        memo << {name: credit["name"], role: credit["role"], id: person.id, yachtski: -1}
      end
    end
    album_personnel
  end

  def includes_track?(all_tracks, person, track_no)
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
