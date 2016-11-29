require 'singleton'

require_relative "resource_simulator"

class WorkerSupervisor
  include Singleton

  def start_request(workers = 1)
    workers.times do
      ResourceSimulator.perform_async
    end
  end
end
