require 'csv'
require 'geoutm'
require 'set'
require 'time'
require 'gruff'

input_file = "od_2007_v2.csv" 
puts "Parsing #{input_file} csv file"

people = []
reasons = {
  1 => "Trabalho Industria",
  2 => "Trabalho Comércio",
  3 => "Trabalho Serviço",
  4 => "Educação",
  5 => "Compras",
  6 => "Saúde",
  7 => "Lazer",
  8 => "Residência",
  9 => "Procurar Emprego",
  10 => "Assuntos Pessoais"
}

parking_types = {
  1 => "Não Estacionou",
  2 => "Zona Azul ou Zona Marrom",
  3 => "Patrocinado",
  4 => "Proprio",
  5 => "Meio-fio",
  6 => "Avulso",
  7 => "Mensal",
  8 => "Não Respondeu",
}

total_factor = 0
people_factor = 0
individuals = Set.new

CSV.foreach(input_file, headers: true, col_sep: ";") do |row|
  by_car = row["MODOPRIN"].to_i == 6 ? true : false
  next unless by_car

  individuals << row["ID_PESS"]
  coordinates_origin = GeoUtm::UTM.new("23K", row["CO_O_X"].to_f, row["CO_O_Y"].to_f).to_lat_lon
  coordinates_destiny =  GeoUtm::UTM.new("23K", row["CO_D_X"].to_f, row["CO_D_Y"].to_f).to_lat_lon
  person = {
    origin_lat: coordinates_origin.lat,
    origin_lon: coordinates_origin.lon,
    destiny_lat: coordinates_destiny.lat,
    destiny_lon: coordinates_destiny.lon,
    factor: row["FE_VIA"].to_f,
    person_factor: row["FE_PESS"].to_f
  }
  person[:reason_origin] = row["MOTIVO_O"]
  person[:reason_destiny] = row["MOTIVO_D"]

  person[:exit_hour] = row["H_SAIDA"].to_i
  person[:exit_minute] = row["MIN_SAIDA"].to_i + rand(-10..10)
  if person[:exit_minute] > 59
    person[:exit_minute] = person[:exit_minute] - 60
    person[:exit_hour] = person[:exit_hour] == 23 ? 0 : person[:exit_hour] + 1
  elsif person[:exit_minute] < 0
    person[:exit_minute] = person[:exit_minute] + 60
    person[:exit_hour] = person[:exit_hour] == 0 ? 23 : person[:exit_hour] - 1
  end
  person[:exit_time] = Time.utc(2007, 4, 30, person[:exit_hour], person[:exit_minute], 0)

  person[:arrive_hour] = row["H_CHEG"].to_i
  person[:arrive_minute] = row["MIN_CHEG"].to_i + rand(-10..10)
  if person[:arrive_minute] > 59
    person[:arrive_minute] = person[:arrive_minute] - 60
    person[:arrive_hour] = person[:arrive_hour] == 23 ? 0 : person[:arrive_hour] + 1
  elsif person[:arrive_minute] < 0
    person[:arrive_minute] = person[:arrive_minute] + 60
    person[:arrive_hour] = person[:arrive_hour] == 0 ? 23 : person[:arrive_hour] - 1
  end
  person[:arrive_time] = Time.utc(2007, 4, 30, person[:arrive_hour], person[:arrive_minute], 0)

  person[:duration] = row["DURACAO"]
  person[:parking_type] = row["TP_ESAUTO"]
  person[:parking_type_string] = parking_types[row["TP_ESAUTO"].to_i]
  total_factor += person[:factor]
  people_factor += person[:person_factor]
  people << person
end

people.sort_by! {|person| person[:arrive_time]}

prev = nil
init_hour = 0
init_min = 0
end_hour = 0
end_min = 30
init_time = Time.utc(2007, 4, 30, init_hour, init_min, 0)
end_time = Time.utc(2007, 4, 30, end_hour, end_min, 0)

#TODO => Agregar por cada meia hora
summary_data = []
summary_data << {factor: 0, label: "#{init_time.hour}:#{init_time.min}"}

people.each do |person|
  data = {}
  reason = person[:reason_destiny].to_i
  next if(reason == 8) # Voltando pra Casa

  if(person[:arrive_time] >= init_time && person[:arrive_time] < end_time)
    data = summary_data.last
    data[:factor] += person[:factor]
  else
    init_time += (30*60)
    end_time += (30*60)
    summary_data << {factor: person[:factor]}
    summary_data.last[:label] = "#{init_time.hour}:#{init_time.min}"
  end
end


puts "Generating charts"
g = Gruff::Bar.new("1600x800")
g.title = 'Expected workload'
i = 0
g.labels = {}
datasets = []
summary_data.each do |data|
  g.labels[i] = data[:label]
  datasets << data[:factor]
  i += 1
end
g.data('drivers', datasets)
g.legend_font_size = 10
g.marker_font_size = 6
g.spacing_factor = 0.5
g.write('output_bar.png')

output_full = "sorted_drivers.csv" 
output_summary = "summary_drivers.csv" 
puts "Creating output files:", output_full, output_summary

CSV.open(output_summary, "w") do |csv|
  headers = []
  summary_data.first.keys.each do |key|
    headers << key.to_s
  end
  csv << headers

  summary_data.each do |summary|
    summary[:factor] = summary[:factor].ceil
    data = []
    summary.each do |key, value|
      data << value
    end
    csv << data
  end
end

CSV.open(output_full, "w") do |csv|
  headers = []
  people.first.keys.each do |key|
    headers << key.to_s
  end
  csv << headers

  people.each do |person|
    data = []
    person.each do |key, value|
      data << value
    end
    csv << data
  end
end

puts "Total #{people.count}"
puts "Total with Factor #{total_factor}"
puts "Individuals: #{individuals.count}"
puts "Individuals with Factor: #{people_factor}"
