require 'JSON'
require 'httparty'

## Extract Shitton of Data From JSON file ##
huge_string = File.read('../capstone-api/lib/assets/points/custom/liquor.json')
huge_json = JSON.parse(huge_string)

huge_json.each do |bar|
  # Find address and bar name
  address = bar["locaddress"]
  common_name = bar["tradename"]
  # Remove address blank spaces at beginning and end, then add + to encode for Google API & downcase
  address.strip!.gsub!(" ", "+").downcase!
  # Geocode bar addresses
  api_call = HTTParty.get("https://maps.googleapis.com/maps/api/geocode/json?address=#{address},+Seattle,+WA&key=[KEYGOESHERE]").parsed_response
  @response = api_call["results"][0]
  # Setup the hash for this bar
  current_hash = {
    "address" => @response["formatted_address"],
    "city_feature" => "Bars",
    "common_name" => common_name,
    "longitude" => @response["geometry"]["location"]["lng"].to_s,
    "latitude" => @response["geometry"]["location"]["lat"].to_s
  }
  json_location = current_hash.to_json
  # Append this bar's JSON to final destination JSON file
  open('../capstone-api/lib/assets/points/custom/bar_geolocation.json', 'a+') { |file|
    file.write(
      json_location
    ) }
  # Append comma/newline between current hash and the next one for parsing final JSON file
  open('../capstone-api/lib/assets/points/custom/bar_geolocation.json', 'a+') { |file|
    file.write(
      ",\n"
    ) }
end
