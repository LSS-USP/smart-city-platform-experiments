#!/usr/bin/env ruby
#encoding: utf-8

require 'csv'
require 'rubygems'
require 'descriptive_statistics'

MAX_TIME = 1.0

if ARGV.empty?
  puts "You need to specify the experiment folder"
  exit 1
end

experiment = ARGV.first

dir_name = File.dirname(File.expand_path(__FILE__))

output = CSV.open("#{dir_name}/#{experiment}/final.csv", "w")
output << [
  'resources',
  'mean',
  'standard_deviation',
  'variance',
  'median',
  'min',
  'max',
  'q1',
  'q2',
  'q3',
  'total',
  'in_sla'
]

Dir.glob(dir_name + "/#{experiment}/*.csv") do |item|
  if item.include?("output_experiment.csv") || item.include?("final.csv")
    next
  end

  pref = dir_name+"/#{experiment}/output_"
  suf = ".csv"
  resources = item[/#{pref}(.*?)#{suf}/m, 1]

  response_time = []
  CSV.foreach(item) {|row| response_time << row[2].to_f}
  
  in_sla_terms = response_time.select{|r| r <= MAX_TIME }.size
  output << [
    resources.to_i,
    response_time.mean,
    response_time.standard_deviation,
    response_time.variance,
    response_time.median,
    response_time.min,
    response_time.max,
    response_time.descriptive_statistics[:q1],
    response_time.descriptive_statistics[:q2],
    response_time.descriptive_statistics[:q3],
    response_time.size,
    in_sla_terms
  ]
end

puts "Final results in #{output.path}"

output.close
