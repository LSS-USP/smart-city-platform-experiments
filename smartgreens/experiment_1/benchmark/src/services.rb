require 'rubygems'
require 'yaml'
require 'erb'

class Services
  SERVICES_FILE = File.read(File.expand_path("config/services.yml"))
  SERVICES_ERB = ERB.new(SERVICES_FILE)
  SERVICES_CONFIG = YAML.load(SERVICES_ERB.result)

  def self.resource_adaptor
    SERVICES_CONFIG['services']['adaptor']
  end

  def self.data_collector
    SERVICES_CONFIG['services']['collector']
  end

  def self.resouce_cataloguer
    SERVICES_CONFIG['services']['cataloguer']
  end
end
