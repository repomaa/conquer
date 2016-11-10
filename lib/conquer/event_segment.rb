require 'celluloid/current'
require 'conquer/core_ext/numeric'
require 'conquer/helpers'

module Conquer
  class EventSegment
    class Worker
      include Celluloid
      include Celluloid::Notifications

      def initialize(topic, block, *subscribed_topics)
        @topic = topic
        @block = wrapped_proc(block)
        subscribed_topics.each { |t| subscribe(t, :handle_event) }
      end

      def handle_event(event, *args)
        publish(@topic, @block.call(event, *args).to_s.chomp)
      end

      private

      def wrapped_proc(block)
        proc { |*args| Helpers.instance_exec(*args, &block) }
      end
    end

    def initialize(topic, interval, block, *subscribed_topics)
      @topic = topic
      @interval = interval
      @block = block
      @subscribed_topics = subscribed_topics
    end

    def start_worker
      Worker.supervise(args: [@topic, @interval, @block, *@subscribed_topics])
    end
  end
end
