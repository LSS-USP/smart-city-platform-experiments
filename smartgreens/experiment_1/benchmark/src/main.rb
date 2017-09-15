#!/usr/bin/env ruby
#encoding: utf-8

require_relative "../environment"
require_relative "services"
require_relative "resource_simulator"
require_relative "worker_supervisor"
require_relative "pedestrian_count"
require_relative "car_position"
require "json"

def test
  resource = ResourceSimulator.new(
    lat: -23.559616,
    lon: -46.731386,
    description: "A simple resource in São Paulo",
    capabilities: ["temperature"],
    external_id: 1,
    type: "TemperatureSensor",
    status: "active"
  )

  trace = [
    {
      capability: "temperature",
      value: "12.8",
      timestamp: "20/08/2016T10:27:40"
    },
    {
      capability: "temperature",
      value: "13.9",
      timestamp: "20/08/2016T10:28:00"
    }
  ]

  puts "="*100, "Registering resources"
  if resource.register && resource.uuid
    print "."
  else
    print "f"
  end
  puts "\n="*100

  resource.set_trace(trace)
  $redis.set(resource.uuid, resource.to_json)
  ResourceSimulator.perform_async(resource.uuid)
end

def execute(manager)
  puts "="*100, "Registering resources"
  manager.register_resources
  puts "="*100, "Registered #{manager.resources.length} resources"

  puts "="*100, "Building traces"
  start = Time.now
  manager.build_trace
  finish = Time.now
  seconds = (finish - start)
  puts "Executed in #{seconds}"

  puts "="*100, "Collecting data"
  start = Time.now
  manager.collect_data
  finish = Time.now
  seconds = (finish - start)
  puts "Executed in #{seconds}"
end

#execute(PedestrianCount.new(200, 2, 1))

execute(CarPosition.new(200, 5, 1, 800))
