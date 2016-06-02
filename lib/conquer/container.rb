require 'celluloid/current'
require 'securerandom'

module Conquer
  class Container
    class Worker
      include Celluloid
      include Celluloid::Notifications

      def initialize(topic, child_topics)
        @topic = topic
        @child_content = {}

        child_topics.each do |child_topic|
          @child_content[child_topic] = ''
          subscribe(child_topic, :update_child_content)
        end
      end

      def update_child_content(topic, content)
        @child_content[topic] = content
        publish(@topic, render(@child_content))
      end

      protected

      def render(child_content)
        child_content.values.join
      end
    end

    attr_reader :children

    def initialize(topic)
      @topic = topic
      @children = {}
    end

    def register(child_class, *args)
      id = SecureRandom.uuid
      @children[id] = child_class.new(id, *args)
    end

    def start_worker
      Worker.supervise(args: [@topic, @children.keys])
      @children.values.each(&:start_worker)
    end
  end
end
