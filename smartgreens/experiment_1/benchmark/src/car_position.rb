#!/usr/bin/env ruby
#encoding: utf-8

require_relative "../environment"
require_relative "resource_simulator"
require "csv"
require "json"

class CarPosition
  attr_accessor :resources, :not_registered
  attr_accessor :requests, :interval, :load_size, :actors, :current_id

  def initialize(requests = 100, interval = 2, load_size = 1, actors = 10)
    @actors = actors
    @requests = requests
    @interval = interval
    @load_size = load_size
    @resources = {}
    @not_registered = {}
    @current_id = 0
  end

  def register_resources
    self.actors.times do
      resource = ResourceSimulator.new(
        lat: -23.54172,
        lon: -46.71637,
        description: "A simple car",
        capabilities: ["location"],
        external_id: self.current_id,
        type: "Car",
        status: "active"
      )

      if resource.register && resource.uuid
        puts "="*100, resource.uuid
        @resources[resource.uuid] = resource
      else
        @not_registered[resource.external_id] = resource
      end
      self.current_id = self.current_id + 1
    end
  end

  def build_trace
    self.load_size.times do
      @resources.each do |uuid, resource|
        if resource
          timestamp = nil
          traces = resource.trace.count
          if traces > self.requests
            next
          elsif traces == 0
            timestamp = DateTime.now.to_s
          else
            # We changed the trace to produce data each 2 seconds
            timestamp = DateTime.parse(resource.trace.last[:timestamp]) + seconds(self.interval)
            timestamp = timestamp.to_s
          end

          data = {
            capability: "location",
            value: [resource.lat + 0.000001, resource.lon + 0.000001],
            timestamp: timestamp
          }
          resource.trace << data
        end
      end
    end
  end

  def collect_data
    @resources.each do |id, resource|
      if resource.trace.count > 0
        $redis.set(resource.uuid, resource.to_json)
        ResourceSimulator.perform_async(resource.uuid)
      end
    end
  end

  private

  def seconds(second)
    Rational(second,86400)
  end
end
