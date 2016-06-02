require 'conquer/version'
require 'conquer/container'
require 'conquer/dsl'
require 'conquer/bar'

module Conquer
  MAIN_TOPIC = 'conquer'.freeze

  def self.bar(io = STDOUT, &block)
    main_container = Container.new(MAIN_TOPIC)
    dsl = DSL.new(main_container)
    dsl.instance_eval(&block)

    Bar.supervise(args: [MAIN_TOPIC, io])
    main_container.start_worker

    sleep
  end
end
