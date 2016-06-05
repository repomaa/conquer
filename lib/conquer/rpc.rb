require 'celluloid/current'
require 'mkfifo'
require 'json'

module Conquer
  class RPC
    include Celluloid
    include Celluloid::Notifications

    def initialize
      File.mkfifo(FIFO) unless File.exist?(FIFO)
      @fifo = File.open(FIFO)

      async.run
    end

    def event(type, *args)
      publish(type, *args)
    end

    private

    def run
      loop do
        command = JSON.parse(@fifo.gets)
        public_send(command['method'], *(command['params'] || []))
      end
    end
  end
end

