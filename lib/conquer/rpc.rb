require 'celluloid/current'
require 'celluloid/io'
require 'json'
require 'socket'

module Conquer
  class RPC
    include Celluloid::IO
    include Celluloid::Notifications
    include Celluloid::Internals::Logger

    def initialize
      info('Starting rpc server')
      @server = UNIXServer.new(RPC_SOCKET)
      async.run
    end

    def shutdown
      @server.close if @server
    end

    def event(type, *args)
      publish(type, *args)
    end

    private

    def run
      loop do
        async.handle_connection(@server.accept)
      end
    end

    def handle_connection(socket)
      info('RPC: connection initiated')
      loop do
        line = socket.gets
        break unless line
        info("RPC: #{line}")
        command = JSON.parse(line)
        public_send(command['method'], *(command['params'] || []))
      end
    end

    def rpc_server(&block)
      UNIXServer.open(RPC_SOCKET) do |server|
        info('RPC: socket opened')
        loop do
          server.accept(&block)
        end
      end
    end
  end
end
