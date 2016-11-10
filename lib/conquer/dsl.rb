require 'conquer/segment'
require 'conquer/event_segment'
require 'conquer/scroller'
require 'conquer/helpers'

module Conquer
  class DSL
    def initialize(container)
      @container = container
    end

    def helpers(&block)
      Helpers.singleton_class.class_eval(&block)
    end

    def separator(string = ' | ', &block)
      if block_given?
        every(100.hours, &block)
      else
        every(100.hours) { string }
      end
    end

    alias static separator

    def every(timespan, &block)
      @container.register(Segment, timespan, block)
    end

    def block(&block)
      every(0, &block)
    end

    def on(*events, &block)
      @container.register(EventSegment, block, *events)
    end

    def scroll(options = {}, &block)
      scroller = @container.register(Scroller, options)
      sub_dsl = DSL.new(scroller)
      sub_dsl.instance_eval(&block)
    end
  end
end
