module PersonnelHelpers

  def build_list(result, title)
    # Pulls track-specific data from result
    track_data = result["tracklist"].find {|track| is_match?(remove_parens(track["title"].downcase), remove_parens(title.downcase)) }
    track_no = track_data["position"]
    title = track_data["title"]

    # Isolates album-only credits and adds them to output hash
    album_credits = result["extraartists"].select{|artist| artist["tracks"] == "" }
    album_personnel = album_credits.inject([]) do |memo, credit|
      if Personnel.find_by(discog_id: credit["id"])
        person = Personnel.find_by(discog_id: credit["id"])
        memo << {name: person.name, role: credit["role"], slug: person.slug, yachtski: person.yachtski}
      else
        memo << {name: credit["name"], role: credit["role"], yachtski: -1, slug: nil}
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
        memo << {name: credit["name"], role: credit["role"], yachtski: -1, slug: nil}
      end
    end

    album_personnel = album_personnel.group_by {|credit| credit[:name]}
    album_personnel = album_personnel.map {|k,v| {name: k, yachtski: v.first[:yachtski], slug: v.first[:slug], roles: v.map{|p| p[:role]} } }
    track_personnel = track_personnel.group_by {|credit| credit[:name]}
    track_personnel = track_personnel.map {|k,v| {name: k, yachtski: v.first[:yachtski], slug: v.first[:slug], roles: v.map{|p| p[:role]} } }

    {
      title: title,
      album_personnel: album_personnel.sort_by {|credit| credit[:yachtski]}.reverse,
      track_personnel: track_personnel.sort_by {|credit| credit[:yachtski]}.reverse,
      yt_id: yt(result["artists"].map {|a| a["name"]}.join(', '), title)
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

  def yt(artist, title)
    base = "https://www.googleapis.com/youtube/v3/search?"
    q = "part=snippet&type=video&videoEmbeddable=true&q=#{artist.downcase.gsub(/[^0-9a-z ]/i, '')} #{title.downcase.gsub(/[^0-9a-z ]/i, '')}&key=#{ENV['YT_KEY']}"
    res = api_call(base+q)
    vid_data = res["items"].first
    vid_data["id"]["videoId"]
  end

end
