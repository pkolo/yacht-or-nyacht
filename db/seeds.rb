require 'json'
require 'net/http'
require 'uri'

uri = URI.parse("https://spreadsheets.google.com/feeds/list/182FzE4GNjjyw8RN9R7fLIOl5GIV-ax00JNuxgdhaUgA/od6/public/values?alt=json")

response = Net::HTTP.get_response(uri)

json_res = JSON.parse(response.body)

json_res["feed"]["entry"].each do |entry|
  artist = Personnel.find_or_create_by(name: entry["gsx$artist"]["$t"], slug: sluggify(entry["gsx$artist"]["$t"]))
  credit = Credit.new(personnel: artist, role: "Artist")
  episode = Episode.find_or_create_by(number: entry["gsx$show"]["$t"])

  song = Song.create(title: entry["gsx$title"]["$t"], year: entry["gsx$year"]["$t"].to_i, jd_score: entry["gsx$jd"]["$t"].to_f, hunter_score: entry["gsx$hunter"]["$t"].to_f, dave_score: entry["gsx$dave"]["$t"].to_f, steve_score: entry["gsx$steve"]["$t"].to_f, episode: episode, slug: sluggify(entry["gsx$title"]["$t"]))
  song.credits << credit
end

u = User.new(name: ENV['ADMIN_NAME'])
u.password = ENV['ADMIN']
u.save
