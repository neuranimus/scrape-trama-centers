require "csv"
require "date"
require "open-uri"
require "net/http"
require "json"

# American Trauma Society Trauma Information Exchange Program (TIEP) scraper
# From https://www.amtrauma.org/page/findtraumacenter

# Example to get directory
# curl 'https://fortress.maptive.com/ver4/data.php?operation=get_map_markers&data_id=13417&map_id=13398&lat_col=12&lng_col=13'

file = open("https://fortress.maptive.com/ver4/data.php?operation=get_map_markers&data_id=13417&map_id=13398&lat_col=12&lng_col=13")
json = file.read

directory = JSON.parse json
ids = []
directory["markers"].map do |marker|
  ids << marker[0]
end

# Example to get map point
#curl 'https://fortress.maptive.com/ver4/data.php?operation=get_bubble_info' \
#  -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8' \
#  --data-raw '&map_id=13398&data_id=13417&id=1953'
CSV.open("#{Date.today.to_s}-tiep-centers.csv", "w") do |csv|
  csv << ["id", "name", "address", "city", "state", "zip", "website", "beds", "state_level", "peds_level", "acs_level", "lat", "lng"]

  ids.each do |id|
    tries = 0

    begin
      params = {
        map_id: 13398,
        data_id: 13417,
        id: id
      }
      response = Net::HTTP.post_form(URI.parse("https://fortress.maptive.com/ver4/data.php?operation=get_bubble_info"), params)
      bubble_json = response.body
      bubble = JSON.parse(bubble_json)["description"]["json"]

      elements = {}
      bubble["columnsData"].each do |elm|
        elements[elm["name"]] = elm["value"]
      end

      csv << [
        bubble["markedId"],
        elements["Name"],
        elements["Address"],
        elements["City"],
        elements["State"],
        elements["Zipcode"],
        elements["Website"],
        elements["Beds"],
        elements["State Designation Level"],
        elements["Pediatric Level"],
        elements["ACS Verification Level"],
        bubble["lat"],
        bubble["lng"]
      ]
    rescue
      if tries < 3
        puts "failed to fetch #{id}, retrying"
        sleep 5
        tries += 1
        retry
      else
        puts "script failed at #{id}"
      end
    end
  end
end
