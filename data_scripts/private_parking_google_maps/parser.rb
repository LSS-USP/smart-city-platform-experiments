require 'nokogiri'
require 'securerandom'
require 'yaml'
require 'google_places'
require 'set'
require 'rest-client'

#CONFIG_FILE = YAML.load(File.read("config.yml"))
#API_KEY = CONFIG_FILE["google_places_key"]
#
#set = Set.new
#@client = GooglePlaces::Client.new(API_KEY)
#spots = @client.spots_by_radar(-23.547995, -46.638605, {radius: 1000, rankby: "distance", types: "parking"})
##spots = @client.spots_by_radar(-33.8670522, 151.1957362, { radius: 10, rankby: "distance", keyword: "Mexican Food" })
#
#places = {
#  usp: {lat: -23.558893, lon: -46.730125, radius: 2000},
#  butanta: {lat: -23.572483605320045, lon: -46.706271171569824, radius: 1000},
#  paraca_por_do_sol: {lat: -23.553576, lon: -46.708963, radius: 1000},
#  pio_xi: {lat: -23.537707509918043, lon: -46.7144250869751, radius: 1000},
#  heitor_penteado: {lat: -23.540514, lon: -46.697079, radius: 1000},
#  sumare: {lat: -23.550735, lon: -46.678081, radius: 1000},
#  beco_batman: {lat: -23.559896036171782, lon: -46.68818235397339, radius: 500},
#  rua_harmonia: {lat: -23.551398745203407, lon: -46.69022083282471, radius: 500},
#  metro_faria_lima: {lat: -23.567104, lon: -46.693836, radius: 800},
#  faria_lima: {lat: -23.57893426693217, lon: -46.68648719787598, radius: 1000},
#  vila_leopoldina: {lat: -23.534087749719475, lon: -46.73352241516133, radius: 1000},
#  acm_gym: {lat: -23.521240, lon: -46.718301, radius: 1000},
#  vila_jaguara: {lat: -23.513607, lon: -46.750342, radius: 2000},
#  hidv: {lat: -23.592794, lon: -46.711047, radius: 2000},
#  vila_olimpia: {lat: -23.591908, lon: -46.677155, radius: 1000},
#  av_brasil: {lat: -23.563082378630043, lon: -46.67982459068298, radius: 500},
#  fradique_coutinho: {lat: -23.567750, lon: -46.683904, radius: 300},
#  av_sao_gabriel: {lat: -23.582972, lon: -46.669828, radius: 700},
#  ibirapuera: {lat: -23.587692, lon: -46.657446, radius: 1000},
#  vila_uberabinha: {lat: -23.595523, lon: -46.667689, radius: 500},
#  moema: {lat: -23.601243638240494, lon: -46.67138636112213, radius: 500},
#  av_dos_bandeirantes: {lat: -23.60396691115929, lon: -46.68790340423584, radius: 800},
#  rua_alvorada: {lat: -23.604183197558815, lon: -46.67761445045471, radius: 300},
#  indianapolis: {lat: -23.607573, -46.672188, radius: 375},
#  jardins: {lat: -23.570910225146108, lon: -46.67391300201416, radius: 700},
#  av_nove_de_julho: {lat: -23.573601, lon: -46.660471, radius: 800},
#  paraiso: {lat: -23.574520, lon: -46.647569, radius: 833},
#  vila_mariana: {lat: -23.587798, lon: -46.640806, radius: 833},
#  vila_clementino: {lat: -23.600462, lon: -46.646514, radius: 833},
#  av_ibirapuera: {lat: -23.602552, lon: -46.660611, radius: 775},
#  rua_oscar_freire: {lat: -23.562473, lon: -46.669452, radius: 600},
#  estacao_paulista: {lat: -23.554801, lon: -46.664817, radius: 600},
#  pacaembu: {lat: -23.547805, lon: -46.664881, radius: 600},
#  cemiterio_consolacao: {lat: -23.551144, -46.656631, radius: 380},
#}

puts "Parsing Openstreetmaps XML file"

doc = File.open("data.osm") { |f| Nokogiri::XML(f) }

nodes = doc.xpath('//node')

parking_data = []
missing_nodes = {}
nodes.each do |node|
  tags = node.xpath('tag')
  if tags.count > 0
    parking = false
    capacity = nil
    tags.each do |tag|
      parking = true if(tag['k'] == "amenity" && tag['v'] == 'parking')
      capacity = tag['v'].to_i if(tag['k'] == "capacity")
    end
    if parking
      data = {openstreetmaps_id: node["id"], lat: node["lat"].to_f, lon: node["lon"].to_f}
      data[:capacity] = capacity.nil? ? rand(20..130) : capacity
      parking_data << data
    end
  else
    missing_nodes[node["id"]] = {openstreetmaps_id: node["id"], lat: node["lat"].to_f, lon: node["lon"].to_f}
  end
end


ways = doc.xpath('//way')

ways.each do |way|
  tags = way.xpath('tag')
  if tags.count > 0
    parking = false
    capacity = nil
    tags.each do |tag|
      parking = true if(tag['k'] == "amenity" && tag['v'] == 'parking')
      capacity = tag['v'].to_i if(tag['k'] == "capacity")
    end
    if parking
      nodes = way.xpath('nd')
      nodes.each do |node|
        if missing_nodes.has_key? node['ref']
          data = missing_nodes[node['ref']]
          data[:capacity] = capacity.nil? ? rand(1..15) : (capacity/nodes.count.to_f).ceil
          parking_data << data
        end
      end
    end
  end
end

total_parking_spots = 0
general = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
  xml.root do
    xml.parking_spots do
      parking_data.each do |data|
        data[:capacity].times do |i|
          xml.spot do
            total_parking_spots += 1
            xml.uuid SecureRandom.uuid
            xml.node_id data[:openstreetmaps_id]
            xml.rotating false
            xml.type "convencional"
            xml.coordinates do
              xml.lat data[:lat]
              xml.lon data[:lon]
            end
            print '.'
          end
        end
      end
    end
  end
end

general.doc.at('parking_spots')['amount'] = total_parking_spots

file_name = "output/parkings_from_open_street_maps.xml"
file = File.open(file_name, "w")
file.write(general.to_xml)


puts "\n\n> Exported #{total_parking_spots} to #{file_name} file"
