module DiscogHelper

  def api_call(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    result = JSON.parse(response.body)
  end

  def search(options, media)
    q = build_query(options, media)
    url = "https://api.discogs.com/database/search?#{q}"
    response = api_call(url)
    response["results"]
  end

  def build_query(options, media)
    q = "type=release&token=#{ENV['DISCOG_TOKEN']}"

    if options.include?("artist")
      q += "&artist=#{media.artist.gsub(/[^0-9a-z ]/i, '')}"
    end

    if options.include?("title")
      q += "&track=#{media.title}"
    end

    if options.include?("year")
      q += "&year=#{media.year}"
    end

    q
  end

  def credits_quality
    title = "Rosanna"
    q = "type=release&token=#{ENV['DISCOG_TOKEN']}&artist=Toto&track=Rosanna&year=1982"
    url = "https://api.discogs.com/database/search?#{q}"
    response = api_call(url)
    results = response["results"].sort_by {|result| result['community']['have']}
    deep_results = results.last(20).map do |result|
      url = "https://api.discogs.com/releases/#{result['id']}"
      api_call(url)
    end

    results_with_count = deep_results.map do |result|
      {
        result: result,
        credit_count: credit_count(result)
      }
    end

    results_with_count.sort_by {|result| result[:credit_count]}.reverse
  end

  def credit_count(result)
    count = 0
    count += result["artists"].length

    if result["tracklist"]
      count += result["tracklist"].sum {|track| track["extraartists"] ? track["extraartists"].length : 0}
    end

    if result["extraartists"]
      count += result["extraartists"].length
    end
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
