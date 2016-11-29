require 'rubygems'
require 'date'
require 'json'
require 'rest-client'

require_relative "../environment"
require_relative "services"

class ResourceSimulator
  attr_accessor :lat, :lon, :description, :capabilities, :status, :uuid
  attr_accessor :external_id, :type, :trace

  def initialize(params={})
    @trace = []
    params.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def set_trace(trace)
    @trace = trace
  end

  def data
    {
      lat: self.lat,
      lon: self.lon,
      description: self.description,
      capabilities: self.capabilities,
      status: self.status
    }
  end

  def to_json
    resource_hash = self.data
    resource_hash[:trace] = self.trace
    resource_hash[:type] = self.type
    resource_hash[:uuid] = self.uuid
    resource_hash[:external_id] = self.external_id
    resource_hash.to_json
  end

  def register
    begin
      response = RestClient.post(
        Services.resource_adaptor + "/components",
        {data: self.data}
      )
      self.uuid = JSON.parse(response.body)['data']['uuid']
      return true
    rescue RestClient::Exception => e
      puts "Could not register resource: #{e.response}"
      return false
    end
  end

  def collect
    resource = self
    Thread.abort_on_exception = true
    Thread.new do
      resource.trace.each_with_index do |t, i|
        puts "Resource #{uuid}, #{i}: #{t}"
        capability = t[:capability]
        value = t[:value]
        timestamp = t[:timestamp]
        data_json = {}
        data_json[capability] = [{value: value, timestamp: timestamp}]
        puts "JSON: #{data_json}"
        begin
          response = RestClient.post(
            Services.resource_adaptor + "/components/#{resource.uuid}/data",
            {data: data_json}
          )
          puts "Success in post data"
        rescue RestClient::Exception => e
          puts "Could not send data: #{e.response}"
        end

        if i+1 < resource.trace.count
          current = DateTime.parse(timestamp)
          future = DateTime.parse(resource.trace[i+1][:timestamp])
          interval = (future.to_time - current.to_time).to_i
          sleep interval
        end
      end
    end
  end
end
