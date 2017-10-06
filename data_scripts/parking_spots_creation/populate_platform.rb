require 'net/http'
require 'uri'
require 'json'
require 'xmlsimple'

puts "[I] Check if parking_monitoring capability exists"

uri_check_capability = URI.parse("http://localhost:8000/catalog/capabilities/parking_monitoring")

http = Net::HTTP.new(uri_check_capability.host, uri_check_capability.port)
request = Net::HTTP::Get.new(uri_check_capability.request_uri, 'Content-Type': 'application/json')
response = http.request(request)

if response.code == "404"

	puts "[I] Creating parking_monitoring capability"

	capability = {
		name: "parking_monitoring",
		description: "Monitor the availability of a parking spot. The field 'available' contains true or false",
		capability_type: "sensor"
	}

	uri_capabilities = URI.parse("http://localhost:8000/catalog/capabilities")
	http = Net::HTTP.new(uri_capabilities.host, uri_capabilities.port)
	request = Net::HTTP::Post.new(uri_capabilities.request_uri, 'Content-Type': 'application/json')
	request.body = capability.to_json

	response = http.request(request)

	if response.code == "422"
		puts "[E] The capability parking_monitoring was not created"
		exit -1
	end

end

puts "[I] Parsing park.xml file"

content = XmlSimple.xml_in('park.xml')


def create_resource(spot)

	puts "[I] Check if parking spot #{spot['uuid']} exists"

	uri_check_resource = URI.parse("http://localhost:8000/catalog/resources/#{spot['uuid']}")
	http = Net::HTTP.new(uri_check_resource.host, uri_check_resource.port)
	request = Net::HTTP::Get.new(uri_check_resource.request_uri, 'Content-Type': 'application/json')
	response = http.request(request)

	if response.code == "404"
		puts "[I] Create parking spot #{spot['uuid']}\n"

		resource = {
			data: {
				description: "Parking Spot",
				uuid: spot['uuid'],
				capabilities: [
					"parking_monitoring"
				],
				status: "active",
				lat: spot['lat'],
				lon: spot['lon']
			}
		}
		
		uri_check_resource = URI.parse("http://localhost:8000/adaptor/resources")
		http = Net::HTTP.new(uri_check_resource.host, uri_check_resource.port)
		request = Net::HTTP::Post.new(uri_check_resource.request_uri, 'Content-Type': 'application/json')
		request.body = resource.to_json
		response = http.request(request)
		
		if response.code == "422"
			puts "[E] The parking spot #{spot['uuid']} was not created"
		else
			puts "[I] Setting parking spot #{spot['uuid']} as available\n"

			capability = {
				data: {
					parking_monitoring: [
						{
							available: "true",
							timestamp: Time.now
						}
					]
				}
			}

			uri_set_capability = URI.parse("http://localhost:8000/adaptor/resources/#{spot['uuid']}/data")
			http = Net::HTTP.new(uri_set_capability.host, uri_set_capability.port)
			request = Net::HTTP::Post.new(uri_set_capability.request_uri, 'Content-Type': 'application/json')
			request.body = capability.to_json
			response = http.request(request)

			if response.code == "422"
				puts "[E] Capability from spot #{spot['uuid']} not setted"
			end
		end

	end
end

class ThreadPool
  def initialize(size:)
    @size = size
    @jobs = Queue.new
    @pool = Array.new(size) do
      Thread.new do
        catch(:exit) do
          loop do
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end

  def schedule(*args, &block)
    @jobs << [block, args]
  end

  def shutdown
    @size.times do
      schedule { throw :exit }
    end

    @pool.map(&:join)
  end
end

pool = ThreadPool.new(size: 5)

content["spot"].each do |spot|
	pool.schedule { create_resource(spot) }
end

pool.shutdown

puts "[I] Finish \o/"

