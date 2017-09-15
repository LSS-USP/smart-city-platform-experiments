require 'rgeo/shapefile'
require 'nokogiri'
require 'securerandom'
require 'geocoder'

def spots_location(amount, segments)
	segments_data = []
	total_length = 0
	segments.each do |segment|
    straight_lines = []
    current_location = nil
    previous_location = nil
    total_distance = 0
    segment.each do |location|
      current_location = location
      unless previous_location.nil?
				distance = Geocoder::Calculations.distance_between(
					[previous_location[1], previous_location[0]],
					[current_location[1], current_location[0]]
				) * 1609.34
				bearing = Geocoder::Calculations.bearing_between(
					[previous_location[1], previous_location[0]],
					[current_location[1], current_location[0]]
				)
				straight_lines << {
					length: distance,
					bearing: bearing,
					start: {lat: previous_location[1], lon: previous_location[0]},
					end: {lat: current_location[1], lon: current_location[0]}
				}
				total_distance += distance
			end	
			previous_location = location
		end
		total_length += total_distance
		segments_data << {length: total_distance, straight_lines: straight_lines}
	end
	
	not_allocated = amount
	segments_data.each do |segment|
		segment[:amount] = ((segment[:length]*amount)/total_length).round
		not_allocated -= segment[:amount]
		segment[:not_allocated] = segment[:amount]
	end
	if not_allocated != 0
		segments_data.last[:amount] += not_allocated
		not_allocated = 0
    segments_data.last[:not_allocated] = segments_data.last[:amount]
	end

	segments_data.each do |segment|
		segment[:straight_lines].each do |line|
			line[:amount] = ((line[:length]*segment[:amount])/segment[:length]).round
			segment[:not_allocated] -= line[:amount]
		end
		if segment[:not_allocated] != 0
			segment[:straight_lines].last[:amount] += segment[:not_allocated]
			segment[:not_allocated] = 0
		end
		segment[:straight_lines].each do |line|
			distance = line[:length]/line[:amount]
			line[:parking_spots] = []
			start = line[:start]
			line[:amount].times do |j|
				spot_location = coordinates_from_bearing(start[:lat], start[:lon], line[:bearing], distance)
				start = spot_location
				line[:parking_spots] << spot_location
			end
		end
	end
	return segments_data
end

# using https://stackoverflow.com/questions/12094484/rails-ruby-calculate-new-coordinates-using-given-distance-and-bearing-from-a-sta
def coordinates_from_bearing(lat_in_degrees, lon_in_degrees, bearing_in_degrees, distance_in_meters, earth_radius=6371.0)
	bearing = bearing_in_degrees * Math::PI / 180
	lat = lat_in_degrees * Math::PI / 180
	lon = lon_in_degrees * Math::PI / 180
	distance = distance_in_meters / 1000
	coordinates = {}
	coordinates[:lat] = Math.asin( Math.sin(lat)*Math.cos(distance/earth_radius) + 
          Math.cos(lat)*Math.sin(distance/earth_radius)*Math.cos(bearing) )
	coordinates[:lon] = lon + Math.atan2(Math.sin(bearing)*Math.sin(distance/earth_radius)*Math.cos(lat), 
                 Math.cos(distance/earth_radius)-Math.sin(lat)*Math.sin(coordinates[:lat]))
	coordinates[:lat] = coordinates[:lat] * 180 / Math::PI
	coordinates[:lon] = coordinates[:lon] * 180 / Math::PI
	coordinates
end

# data = spots_location(272, [[[-46.664937, -23.544822], [-46.664846, -23.545453], [-46.664826, -23.545876], [-46.664802, -23.546194], [-46.664785, -23.546466], [-46.66477, -23.546493], [-46.664727, -23.546618], [-46.664717, -23.546699], [-46.664719, -23.546719], [-46.664721, -23.546771], [-46.664732, -23.54683], [-46.66475, -23.546894], [-46.664781, -23.546961], [-46.664797, -23.546984], [-46.664831, -23.547039], [-46.664927, -23.547133], [-46.665004, -23.547184]], [[-46.665202, -23.545985], [-46.665278, -23.544826]], [[-46.664999, -23.546248], [-46.665062, -23.546217], [-46.665174, -23.546184]], [[-46.665615, -23.546678], [-46.665614, -23.54676], [-46.665601, -23.546807], [-46.665582, -23.546849], [-46.665552, -23.546889], [-46.66553, -23.546916], [-46.665468, -23.546959], [-46.665396, -23.54699], [-46.665343, -23.547001], [-46.665279, -23.547001], [-46.665223, -23.546993], [-46.665164, -23.546973], [-46.665102, -23.546935], [-46.665066, -23.546901], [-46.66504, -23.546866], [-46.665015, -23.546822], [-46.664998, -23.546779], [-46.664993, -23.546719], [-46.664995, -23.546666]], [[-46.664917, -23.54621], [-46.66494, -23.545864], [-46.664955, -23.545629], [-46.664973, -23.545373], [-46.665001, -23.545209], [-46.665047, -23.545038], [-46.665123, -23.544874]], [[-46.665514, -23.547223], [-46.665638, -23.547168], [-46.665765, -23.547055], [-46.665823, -23.546974], [-46.66588, -23.54682], [-46.665884, -23.546724], [-46.665884, -23.546651], [-46.665868, -23.546592], [-46.665845, -23.54652]]])

# spots_location(12, [[[-46.641048119999994, -23.636382029999996], [-46.64029608, -23.63589999], [-46.640167919999996, -23.635776959999998], [-46.64012508, -23.635698029999997], [-46.640069999999994, -23.63560299]]])

# spots_location(32, [[[-46.64108484, -23.63654403], [-46.640143079999994, -23.635917], [-46.640076119999996, -23.635850039999998], [-46.64000196, -23.635731959999998], [-46.639941119999996, -23.635575], [-46.639910879999995, -23.635344959999998], [-46.63987416, -23.635104029999997], [-46.639856159999994, -23.634981], [-46.63980684, -23.634818999999997], [-46.63973916, -23.63461704], [-46.63955016, -23.63428098], [-46.639365839999996, -23.634044999999997]]])


puts "="*100, "Reading shapefiles to create a XML file with Zona Azul parking spots", "="*100
total_parking_spots = 0


general = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
  xml.root do
    xml.parking_spots do
      RGeo::Shapefile::Reader.open("shapefiles/ZonaAzulFaces.shp") do |file|
        file.each do |record|
          spots = record.attributes['vagasAuto'].to_i + record.attributes['vagasCamin'].to_i + record.attributes['vagasFreta'].to_i + record.attributes['vagasIdoso'].to_i + record.attributes['vagasDefis'].to_i
          available_spots = {
            "idoso" => record.attributes['vagasIdoso'],
            "caminhao" => record.attributes['vagasCamin'],
            "defis" => record.attributes['vagasDefis'],
            "fretamento" => record.attributes['vagasFreta'],
            "convencional" => record.attributes['vagasAuto'],
          }
          available_spots.delete_if{|key, value| value.to_i == 0}
          segments_data = spots_location(spots, record.geometry.coordinates)
          segments_data.each do |segment|
            segment[:straight_lines].each do |line|
              line[:parking_spots].each do |spot|
                type = available_spots.keys.sample
                next if type.nil?
                xml.spot do
                  total_parking_spots += 1
                  xml.type = type
                  available_spots[type] -= 1
                  available_spots.delete(type) if available_spots[type] <= 0
                  xml.uuid SecureRandom.uuid
                  xml.local record.attributes["local"]
                  xml.complement record.attributes["corredor"]
                  xml.coordinates do
                    xml.lat spot[:lat]
                    xml.lon spot[:lon]
                  end
                  xml.rotating true
                  xml.rotating_rules do
                    rule_id = record.attributes['idRegra1']
                    valid_rule = rule_id != 0
                    xml.rule(number: "1", active: valid_rule, rule_id: rule_id) do
                      xml.tempo_cartao record.attributes['r1TempoCar']
                      xml.inicio_seg_sex record.attributes['r1Inic2a6a']
                      xml.fim_seg_sex record.attributes['r1Term2a6a']
                      xml.inicio_sab record.attributes['r1InicSab']
                      xml.fim_sab record.attributes['r1TermSab']
                      xml.inicio_dom record.attributes['r1InicDom']
                      xml.fim_dom record.attributes['r1TermDom']
                    end

                    rule_id = record.attributes['idRegra2']
                    valid_rule = rule_id != 0
                    xml.rule(number: "2", active: valid_rule, rule_id: rule_id) do
                      xml.tempo_cartao record.attributes['r2TempoCar']
                      xml.inicio_seg_sex record.attributes['r2Inic2a6a']
                      xml.fim_seg_sex record.attributes['r2Term2a6a']
                      xml.inicio_sab record.attributes['r2InicSab']
                      xml.fim_sab record.attributes['r2TermSab']
                      xml.inicio_dom record.attributes['r2InicDom']
                      xml.fim_dom record.attributes['r2TermDom']
                    end

                    rule_id = record.attributes['idRegra3']
                    valid_rule = rule_id != 0
                    xml.rule(number: "3", active: valid_rule, rule_id: rule_id) do
                      xml.tempo_cartao record.attributes['r3TempoCar']
                      xml.inicio_seg_sex record.attributes['r3Inic2a6a']
                      xml.fim_seg_sex record.attributes['r3Term2a6a']
                      xml.inicio_sab record.attributes['r3InicSab']
                      xml.fim_sab record.attributes['r3TermSab']
                      xml.inicio_dom record.attributes['r3InicDom']
                      xml.fim_dom record.attributes['r3TermDom']
                    end
                  end
                end
              end
            end
          end
        end
      end
      RGeo::Shapefile::Reader.open("shapefiles/ZonaAzulVagas.shp") do |file|
        file.each do |record|
          record.attributes["Quantidade"].to_i.times do |i|
            xml.spot do
              total_parking_spots += 1
              xml.uuid SecureRandom.uuid
              xml.local record.attributes["Local"]
              xml.complement record.attributes["Complement"]
              xml.rotating false
              type = case record.attributes["Tipo"]
                     when "ID" then "idoso"
                     when "CA" then "caminhao"
                     when "DF" then "defis"
                     when "FR" then "fretamento"
                     when "MO" then "moto"
                     else "convencional"
                     end
              xml.type type
              xml.coordinates do
                xml.lat record.geometry.coordinates[1]
                xml.lon record.geometry.coordinates[0]
              end
            end
          end
        end
      end
      RGeo::Shapefile::Reader.open("shapefiles/ZonaAzulVagasNaoRotativas.shp") do |file|
        file.each do |record|
          record.attributes["Quantidade"].to_i.times do |i|
            xml.spot do
              total_parking_spots += 1
              xml.uuid SecureRandom.uuid
              xml.uuid SecureRandom.uuid
              xml.local record.attributes["Local"]
              xml.complement record.attributes["Complement"]
              xml.rotating false
              type = case record.attributes["Tipo"]
                     when "ID" then "idoso"
                     when "CA" then "caminhao"
                     when "DF" then "defis"
                     when "FR" then "fretamento"
                     when "MO" then "moto"
                     else "convencional"
                     end
              xml.type type
              xml.coordinates do
                xml.lat record.geometry.coordinates[1]
                xml.lon record.geometry.coordinates[0]
              end
            end
          end
        end
      end
    end
  end
end

general.doc.at('parking_spots')['amount'] = total_parking_spots

file_name = "output/vagas_zona_azul.xml"
file = File.open(file_name, "w")
file.write(general.to_xml)


puts "> Exported #{total_parking_spots} to #{file_name} file"
