#!/usr/bin/env ruby
#encoding: utf-8

require_relative "../environment"
require_relative "resource_simulator"
require "csv"
require "json"

class Temperature
  attr_accessor :resources, :not_registered
  attr_accessor :requests, :interval, :load_size, :actors, :current_id, :experiment_time

  def initialize(experiment_time = 60, interval = 1, load_size = 1, actors = 10)
    @actors = actors
    @experiment_time = experiment_time
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
        description: "A simple temperature",
        capabilities: ["temperature"],
        external_id: self.current_id,
        type: "Temperature",
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
    collections = (experiment_time/interval).to_i
    puts "Building #{collections} requests per resource"

    self.load_size.times do
      @resources.each do |uuid, resource|
        if resource
          collections.times do |collection|
            traces = resource.trace.count
            if traces == 0
              timestamp = DateTime.now.to_s
            else
              timestamp = DateTime.parse(resource.trace.last[:timestamp]) + seconds(self.interval)
              timestamp = timestamp.to_s
            end

            data = {
              capability: "temperature",
              value: "18.9",
              timestamp: timestamp
            }
            resource.trace << data
          end
        end
      end
    end
  end

  def collect_data
    threads = []
    @resources.each do |id, resource|
      if resource.trace.count > 0
        puts "Collecting data from resource #{id}"
        threads << resource.collect
      end
    end
    threads.each_with_index do |thread, i|
      puts "Waiting thread #{i}"
      thread.join
    end
    puts "="*100, "All threads finished"
  end

  private

  def seconds(second)
    Rational(second,86400)
  end
end
