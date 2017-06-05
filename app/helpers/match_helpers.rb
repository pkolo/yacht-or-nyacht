def is_match?(str1, str2)
  fuzzy = FuzzyStringMatch::JaroWinkler.create( :pure )
  match = fuzzy.getDistance(str1, str2)
  match >= 0.85
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

def remove_parens(string)
  string.gsub(/\([^)]*\)/, '')
end

def song_match(q)
  Song.all.select { |song| is_match?(remove_parens(song.title.downcase), q.downcase) }
end

def personnel_match(q)
  Personnel.all.select { |person| is_match?(person.name.downcase, q.downcase) }
end
