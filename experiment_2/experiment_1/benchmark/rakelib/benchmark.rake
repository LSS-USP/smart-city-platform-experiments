require 'yaml'
require 'date'
require 'json'
require 'csv'
require 'nkf'
require_relative '../src/car_position'
require_relative '../src/resource_simulator'
require_relative "../src/services"

ACTORS = ENV['EXPERIMENT_ACTORS'].to_i || 20000
REQUESTS = ENV['EXPERIMENT_REQUESTS'].to_i || 50
TIME = ENV['EXPERIMENT_TIME'].to_i || 120
EXPERIMENTS = ENV['EXPERIMENT_NUMBER'].to_i || 1
MONITORING_TIME = ENV['MONITORING_TIME'].to_i || 1
MAX_NUMBER = 20000

namespace :benchmark do
  desc 'Start benchmark monitoring'
  task :monitor do
    command =  "cd ../ansible && ansible-playbook monitor.yml --extra-vars 'collecting_time=#{MONITORING_TIME}s'"
    puts "Running ansible monitoring command:", command, "="*100
    system(command)
  end

  desc 'Start bench'
  task :run do
    file = output_file

    manager = CarPosition.new(1, 1, 1, 1)
    manager.register_resources
    manager.build_trace

    manager.actors = ACTORS
    manager.requests = REQUESTS

    # Wait the register of all resources
    sleep 5

  
    EXPERIMENTS.times do |i|
      begin
        puts "="*100, "Executing experiment #{i}"
        execute_benchmark(file, manager.actors * manager.requests, manager.actors, manager.resources.keys.first)
        puts "Finishing experiment #{i}"
      rescue Exception => e
        puts "!"*100, "Failed to run Experiment #{i}: #{e}"
      end
      # Wait to close some TCP connections
      sleep 60
    end
    file.close
    exit 0
  end

  desc 'Start bench'
  task :load do
    file = output_file

    manager = CarPosition.new(1, 1, 1, 1)
    manager.register_resources
    manager.build_trace

    manager.actors = ACTORS
    manager.requests = REQUESTS

    # Wait the register of all resources
    sleep 5


    EXPERIMENTS.times do |i|
      actors_load = 256
      while true
        break if actors_load > MAX_NUMBER
        begin
          puts "="*100, "Executing experiment with load #{actors_load}"
          execute_benchmark(file, actors_load * manager.requests, actors_load, manager.resources.keys.first)
          puts "Finishing experiment #{actors_load}"
        rescue Exception => e
          puts "!"*100, "Failed to run Experiment #{actors_load}: #{e}"
        end
        actors_load = actors_load * 2
        # Wait to close some TCP connections
        sleep 60
      end
    end
    file.close
    exit 0
  end

  def execute_benchmark(file, requests, actors, uuid)
    json_file = File.expand_path('../../files/jsons/car.json', __FILE__)
    command = "ab -r -p #{json_file} -T application/json -t #{TIME} -c #{actors} -s 120 -g results/load_#{actors}.tsv -e results/load_#{actors}.csv  #{Services.resource_adaptor}/components/#{uuid}/data"

    puts "Running $ #{command}"
		h = {}
		IO.popen(command, "r") {|io|
			while str = io.gets
				e = str.scan(/^(.+):\s+(.+)/)
				h[e[0][0]] = e[0][1] if e.length > 0
			end
		}

		file.print "#{Services.resource_adaptor},#{actors},#{h['Server Software']},#{h['Server Hostname']},#{h['Server Port']}," + 
		"#{h['Document Path']},#{h['Document Length'].scan(/\d+/).pop}," + 
		"#{h['Concurrency Level']},#{h['Time taken for tests'].scan(/[\d\.]+/).pop}," +
		"#{h['Complete requests']},#{h['Failed requests']},#{h['Write errors']}," + 
		"#{h['Total transferred'].scan(/\d+/).pop},#{h['HTML transferred'].scan(/\d+/).pop}," +
		"#{h['Requests per second'].scan(/[\d\.]+/).pop},#{h['Time per request'].scan(/[\d\.]+/).pop}," +
		"#{h['Transfer rate'].scan(/[\d\.]+/).pop}," + 
		"#{h['Connect'].gsub(/[\s\t]+/,',')},#{h['Processing'].gsub(/[\s\t]+/,',')},#{h['Waiting'].gsub(/[\s\t]+/,',')},#{h['Total'].gsub(/[\s\t]+/,',')}" +
		"\n"
	end
end

def output_file
	file_name = File.expand_path("../../results/output.csv", __FILE__)
  f = open(file_name, "w")
  f.print "URL,C,Server Software,Server Hostname,Server Port," +
    "Document Path,Document Length[bytes]," +
    "Concurrency Level,Time taken for tests[s]," +
    "Complete requests,Failed requests,Write errors," +
    "Total transferred[bytes],HTML transferred[bytes]," +
    "Requests per second[#/sec](mean),Time per request[ms](mean - across all concurrent requests)," +
    "Transfer rate[bytes/s]," +
      "Connect-min[ms],Connect-mean[ms],Connect-[+/-sd],Connect-median[ms],Connect-max[ms]," +
      "Processing-min[ms],Processing-mean[ms],Processing-[+/-sd],Processing-median[ms],Processing-max[ms]," +
      "Waiting-min[ms],Waiting-mean[ms],Waiting-[+/-sd],Waiting-median[ms],Waiting-max[ms]," +
      "Total-min[ms],Total-mean[ms],Total-[+/-sd],Total-median[ms],Total-max[ms]" +
      "\n"
  return f
end
