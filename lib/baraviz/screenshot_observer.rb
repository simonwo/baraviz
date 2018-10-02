require 'capybara-screenshot'
require_relative 'observer'

module Baraviz
  class ScreenshotObserver < Observer
    def initialize session, screenshot_dir
      @screenshots = {}
      @dir = screenshot_dir
      super session
    end

    def observe_page page
      @screenshots[page] ||= take_screenshot
      super
    end

    def take_screenshot
      path = File.join @dir, "#{Capybara.current_url.gsub(/[^A-Za-z0-9_\-]/, '-')}.png"
      result = Capybara::Screenshot.registered_drivers.fetch(Capybara.current_driver) do |driver_name|
        warn "capybara-screenshot could not detect a screenshot driver for '#{Capybara.current_driver}'. Saving with default with unknown results."
        Capybara::Screenshot.registered_drivers[:default]
      end.call(Capybara.page.driver, path)
      if (result == :not_supported) then nil else File.basename(path) end
    end

    def make_node v
      uri = URI.parse v.to_s
      RGL::DOT::Node.new({'name' => v, 'label' => uri.path, 'image' => @screenshots[v], 'URL' => @screenshots[v]}, RGL::DOT::NODE_OPTS + ['image'])
    end
  end
end