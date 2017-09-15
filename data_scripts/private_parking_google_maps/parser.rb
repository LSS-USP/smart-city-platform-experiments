require 'nokogiri'
require 'securerandom'
require 'yaml'

CONFIG_FILE = YAML.load(File.read("config.yml"))
API_KEY = CONFIG_FILE["google_places_key"]

puts "+"*100, API_KEY
exit 0

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

file_name = "output/parkings_from_google_places.xml"
file = File.open(file_name, "w")
file.write(general.to_xml)


puts "> Exported #{total_parking_spots} to #{file_name} file"
