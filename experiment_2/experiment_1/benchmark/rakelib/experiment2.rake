require 'yaml'
require 'date'
require 'json'
require 'csv'
require 'nkf'
require_relative '../src/temperature'
require_relative '../src/resource_simulator'
require_relative "../src/services"

ACTORS = ENV.has_key?('EXPERIMENT_ACTORS') ? ENV['EXPERIMENT_ACTORS'].to_i : 10
INTERVAL = ENV.has_key?('EXPERIMENT_INTERVAL') ? ENV['EXPERIMENT_INTERVAL'].to_i : 1
TIME = ENV.has_key?('EXPERIMENT_TIME') ? ENV['EXPERIMENT_TIME'].to_i : 10
EXPERIMENTS = ENV.has_key?('EXPERIMENT_NUMBER') ? ENV['EXPERIMENT_NUMBER'].to_i : 1
MAX_NUMBER = 20000

namespace :experiment2 do
  desc 'Start bench'
  task :run do
    manager = Temperature.new(TIME, INTERVAL, 1, ACTORS)

    puts "Time: #{TIME}, Interval: #{INTERVAL}, Actors: #{ACTORS}"
    
    puts "="*100, "Registering resources"
    manager.register_resources
    puts "="*100, "Registered #{manager.resources.length} resources"

    puts "="*100, "Building traces"
    start = Time.now
    manager.build_trace
    finish = Time.now
    seconds = (finish - start)
    puts "Executed in #{seconds}"

    # Wait the register of all resources
  
    begin    
      puts "="*100, "Executing experiment"
      start = Time.now
      manager.collect_data
      finish = Time.now
      puts "Finishing experiment"
      puts "Executed in #{(finish-start)}"
    rescue Exception => e
      puts "!"*100, "Failed to run Experiment: #{e}"
    end
    # Wait to close some TCP connections
    #sleep 60
    exit 0
  end
end

