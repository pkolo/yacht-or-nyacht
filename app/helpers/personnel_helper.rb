module PersonnelHelper

  def build_list(result, title)
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
