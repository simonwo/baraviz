require 'rgl/adjacency'
require 'capybara'

module Baraviz
  class Observer
    attr_reader :graph

    def initialize session
      @graph = RGL::DirectedAdjacencyGraph.new
      install_capybara_hooks! session
    end

    def install_capybara_hooks! session
      this = self
      Capybara::Session::DSL_METHODS.each do |method|
        session.define_singleton_method :"_#{method}_old", &session.method(method)
        session.define_singleton_method method do |*args, &block|
          old_page = session.method(:"_current_url_old").call
          result = session.method(:"_#{method}_old").call(*args, &block)
          new_page = session.method(:"_current_url_old").call

          if old_page != new_page
            this.observe_page_change old_page, new_page
          end

          result
        end
      end
    end

    def observe_page_change old_page, new_page
      @graph.add_edge old_page, new_page
    end
  end
end
