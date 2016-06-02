require 'celluloid/current'

module Conquer
  class Bar
    include Celluloid
    include Celluloid::Notifications

    def initialize(topic, io)
      @io = io
      subscribe(topic, :puts)
    end

    def puts(_, content)
      @io.puts(content)
      @io.flush
    end
  end
end
