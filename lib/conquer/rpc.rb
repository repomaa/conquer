require 'celluloid/current'
require 'json'

module Conquer
  class RPC
    include Celluloid
    include Celluloid::Notifications

    def initialize
      async.run
    end

    def event(type, *args)
      publish(type, *args)
    end

    private

    def run
      File.mkfifo(FIFO) unless File.exist?(FIFO)
      File.open(FIFO) do |fifo|
        loop do
          IO.select([fifo])
          line = fifo.gets
          next unless line
          command = JSON.parse(line)
          public_send(command['method'], *(command['params'] || []))
        end
      end
    end
  end
end
