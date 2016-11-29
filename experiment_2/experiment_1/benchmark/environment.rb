#!/usr/bin/env ruby
#encoding: utf-8

require_relative 'src/services'
require_relative 'src/resource_simulator'
#require_relative 'src/worker_supervisor'
#require 'sidekiq'
#require "redis"
#
#redis_host = ENV['REDIS_HOST'] || '127.0.0.1'
#port = ENV['REDIS_PORT'] || '6379'
#Sidekiq.configure_server do |config|
#  config.redis = { url: "redis://#{redis_host}:#{port}" }
#  config.average_scheduled_poll_interval = 1
#end
#
#Sidekiq.configure_client do |config|
#  config.redis = { url: "redis://#{redis_host}:#{port}" }
#end
#
#$redis = Redis.new(host: redis_host, port: port)
