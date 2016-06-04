require 'celluloid/current'
require 'conquer/core_ext/numeric'
require 'conquer/helpers'

module Conquer
  class Segment
    class Worker
      include Celluloid
      include Celluloid::Notifications

      DRIFT = 100.milliseconds.freeze

      def initialize(topic, interval, block)
        @topic = topic
        @interval = interval
        @block = wrapped_proc(block)

        async.run
      end

      protected

      def run
        loop do
          publish(@topic, @block.call.to_s.chomp)
          sleep @interval + rand(0..DRIFT)
        end
      end

      def render(child_content)
        child_content.join
      end

      private

      def wrapped_proc(block)
        proc { Helpers.instance_eval(&block) }
      end
    end

    def initialize(topic, interval, block)
      @topic = topic
      @interval = interval
      @block = block
    end

    def start_worker
      Worker.supervise(args: [@topic, @interval, @block])
    end
  end
end
