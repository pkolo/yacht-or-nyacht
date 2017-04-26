require 'json'
require 'net/http'
require 'uri'

uri = URI.parse("https://spreadsheets.google.com/feeds/list/1xQbknvF7FuTJcsVBLgm1KlkozUhVVpJiyVOjvtSol0E/od6/public/values?alt=json")

response = Net::HTTP.get_response(uri)

json_res = JSON.parse(response.body)
