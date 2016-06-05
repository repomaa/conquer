require 'conquer/version'
require 'conquer/container'
require 'conquer/dsl'
require 'conquer/bar'
require 'conquer/rpc'

module Conquer
  MAIN_TOPIC = 'conquer'.freeze

  @startup_hooks = []

  module_function

  def bar(io = STDOUT, &block)
    main_container = Container.new(MAIN_TOPIC)
    dsl = DSL.new(main_container)
    dsl.instance_eval(&block)

    @startup_hooks.each(&:call)

    RPC.supervise
    Bar.supervise(args: [MAIN_TOPIC, io])
    main_container.start_worker

    sleep
  end

  def on_startup(&block)
    @startup_hooks << block
  end
end
