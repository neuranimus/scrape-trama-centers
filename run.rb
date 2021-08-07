require "csv"
require "date"
require "open-uri"
require "nokogiri"

file = open("https://www.facs.org/search/trauma-centers")
html = file.read
document = Nokogiri::HTML.parse(html)

elms = document.css("#content_element_0_left_column_1_state option[value]:not([value=\"\"])")
states = elms.map{|e| e.values[0]}

CSV.open("#{Date.today.to_s}-centers.csv", "w") do |csv|

  csv << ["name", "address", "state", "country", "adult_level", "pediatric_level"]

  states.each do |state|
    file = open("https://www.facs.org/search/trauma-centers?state=#{state}&n=250")
    html = file.read
    document = Nokogiri::HTML.parse(html)

    centers = document.css(".searchResults ul").each do |elm|
      name = elm.css("li h3").text
      address = elm.css("li[2]").text
      country = elm.css("li[3]").text
      elm.css("li[4] span").remove
      level = elm.css("li[4]").text

      pediatric_level = ""
      adult_level = ""
      level.split(",").each do |l|
        if /Pediatric/ =~ l
          pediatric_level = l.strip
        else
          adult_level = l.strip
        end
      end

      csv << [name, address, state, country, adult_level, pediatric_level]
    end
  end
end
