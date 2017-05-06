require 'json'
require 'net/http'
require 'uri'

uri = URI.parse("https://spreadsheets.google.com/feeds/list/1xQbknvF7FuTJcsVBLgm1KlkozUhVVpJiyVOjvtSol0E/od6/public/values?alt=json")

response = Net::HTTP.get_response(uri)

json_res = JSON.parse(response.body)

json_res["feed"]["entry"].each do |entry|
  artist = Personnel.find_or_create_by(name: entry["gsx$artist"]["$t"])
  credit = Credit.new(personnel: artist, role: "Artist")
  episode = Episode.find_or_create_by(number: entry["gsx$show"]["$t"])

  song = Song.create(title: entry["gsx$title"]["$t"], year: entry["gsx$year"]["$t"].to_i, jd_score: entry["gsx$jdryznar"]["$t"].to_f, hunter_score: entry["gsx$hunterstair"]["$t"].to_f, dave_score: entry["gsx$davelyons"]["$t"].to_f, steve_score: entry["gsx$stevehuey"]["$t"].to_f, episode: episode)
  song.credits << credit
end
