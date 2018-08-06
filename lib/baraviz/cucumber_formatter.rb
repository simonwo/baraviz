require 'cucumber/formatter/io'
require 'rgl/dot'
require_relative 'observer'

module Baraviz
  class CucumberFormatter
    include Cucumber::Formatter::Io

    def initialize config
      @io = ensure_io config.out_stream
      config.on_event :test_run_started,  &method(:on_test_run_started)
      config.on_event :test_run_finished, &method(:on_test_run_finished)
    end

    def on_test_run_started event
      @observer = Baraviz::Observer.new Capybara.current_session
    end

    def on_test_run_finished event
      @io.write @observer.clustered_graph.to_s
      @io.close
    end
  end
end
