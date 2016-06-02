require 'conquer/container'

module Conquer
  class Scroller < Container
    class Worker < Container::Worker
      def initialize(topic, child_topics, options)
        super(topic, child_topics)
        @options = options
        @scroll_position = 0

        async.run
      end

      def update_child_content(*)
        @scroll_position = 0
        super
      end

      protected

      def render(child_content)
        @content = super
        visible_content = @content[@scroll_position, @options[:width]]
        visible_content.ljust(@options[:width])
      end

      private

      def run
        loop do
          publish(@topic, render(@child_content))
          advance_scroll_position

          sleep(1.0 / @options[:speed])
        end
      end

      def advance_scroll_position
        content_size = @content.size
        scroll_position = @scroll_position + @options[:step]
        margin = @options[:width] - @options[:step]
        scroll_position = 0 if scroll_position > (content_size - margin)

        @scroll_position = scroll_position
      end
    end

    DEFAULT_OPTIONS = {
      speed: 1,
      width: 20,
      every: 0,
      step: 2
    }.freeze

    def initialize(topic, options)
      super(topic)
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def start_worker
      Worker.supervise(args: [@topic, @children.keys, @options])
      @children.values.each(&:start_worker)
    end
  end
end
