require 'cucumber/formatter/io'
require 'rgl/dot'
require_relative 'screenshot_observer'

module Baraviz
  class CucumberFormatter
    include Cucumber::Formatter::Io

    def initialize config
      @io = ensure_file config.out_stream, Baraviz.name
      config.on_event :test_run_started,  &method(:on_test_run_started)
      config.on_event :test_run_finished, &method(:on_test_run_finished)
      config.on_event :test_case_finished, &method(:on_test_case_finished)
    end

    def on_test_run_started event
      screenshot_dir = File.dirname @io.path
      @observer = Baraviz::ScreenshotObserver.new Capybara.current_session, screenshot_dir
    end

    def on_test_run_finished event
      @io.write @observer.graph.to_s
      @io.close
    end

    def on_test_case_finished event
      @observer.forget_next!
    end
  end
end
