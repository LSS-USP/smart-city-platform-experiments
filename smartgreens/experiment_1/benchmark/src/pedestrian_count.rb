#!/usr/bin/env ruby
#encoding: utf-8

require_relative "../environment"
require_relative "resource_simulator"
require "csv"
require "json"

class PedestrianCount
  attr_accessor :resources, :not_registered
  attr_accessor :data_file, :meta_data_file
  attr_accessor :requests, :interval, :load_size

  def initialize(requests, interval = 2, load_size = 1)
    @requests = requests
    @interval = interval
    @load_size = load_size
    @data_file = File.expand_path('../../files/melbourne/Pedestrian_Counts.csv', __FILE__)
    @meta_data_file = File.expand_path('../../files/melbourne/Pedestrian_Sensor_Locations.csv', __FILE__)
    @resources = {}
    @not_registered = {}
  end

  def register_resources
    CSV.foreach(@meta_data_file, headers: true) do |row|
      resource = ResourceSimulator.new(
        lat: row["Latitude"],
        lon: row["Longitude"],
        description: row["Sensor Description"],
        capabilities: ["current_users"],
        external_id: row["Sensor ID"],
        type: "PedestrianCount",
        status: "active"
      )

      if resource.register && resource.uuid
        @resources[row["Sensor ID"]] = resource
      else
        @not_registered[row["Sensor ID"]] = resource
      end
    end
  end

  def build_trace
    self.load_size.times do
      CSV.foreach(@data_file, headers: true) do |row|
        resource = @resources[row["Sensor_ID"]]
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
            capability: "current_users",
            value: row["Hourly_Counts"],
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
