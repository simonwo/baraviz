require 'rgl/adjacency'
require 'rgl/dot'
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

    def clustered_graph
      subgraphs = Hash.new do |h, uri|
        h[uri] = RGL::DOT::Subgraph.new('name' => "cluster_#{uri[0]}:#{uri[1]}", 'label' => "#{uri[0]}:#{uri[1]}")
      end

      @graph.each_vertex do |v|
        uri = URI.parse v.to_s
        subgraph = subgraphs[[uri.host, uri.port]]
        subgraph << RGL::DOT::Node.new('name' => v, 'label' => v.to_s)
      end

      graph = RGL::DOT::Digraph.new
      subgraphs.values.each &graph.method(:<<)
      @graph.each_edge do |u, v|
        graph << RGL::DOT::DirectedEdge.new('from' => u, 'to' => v)
      end

      graph
    end
  end
end
