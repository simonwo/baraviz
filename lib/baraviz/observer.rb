require 'rgl/adjacency'
require 'rgl/dot'
require 'capybara'

module Baraviz
  class Observer
    attr_accessor :external_call

    def initialize session
      @graph = RGL::DirectedAdjacencyGraph.new
      @external_call = true
      install_capybara_hooks! session
    end

    def install_capybara_hooks! session
      this = self
      Capybara::Session::DSL_METHODS.each do |method|
        session.define_singleton_method :"_#{method}_old", &session.method(method)
        session.define_singleton_method method do |*args, &block|
          external_call = this.external_call
          this.external_call = false

          begin
            old_page = session.method(:"_current_url_old").call
            this.observe_page old_page if external_call

            result = session.method(:"_#{method}_old").call(*args, &block)
            new_page = session.method(:"_current_url_old").call
            this.observe_page new_page if external_call

            if external_call && old_page != new_page
              this.observe_page_change old_page, new_page
            end

            result
          ensure
            this.external_call = true if external_call
          end
        end
      end
    end

    def observe_page page
      # Called for subclasses
    end

    def observe_page_change old_page, new_page
      @graph.add_edge old_page, new_page
    end

    def make_node v
      uri = URI.parse v.to_s
      RGL::DOT::Node.new({'name' => v, 'label' => uri.path})
    end

    def make_edge u, v
      RGL::DOT::DirectedEdge.new('from' => u, 'to' => v)
    end

    def graph
      graph = RGL::DOT::Digraph.new
      @graph.each_vertex do |v|
        graph << make_node(v)
      end

      @graph.each_edge do |u, v|
        graph << make_edge(u, v)
      end

      graph
    end

    def clustered_graph
      subgraphs = Hash.new do |h, uri|
        h[uri] = RGL::DOT::Subgraph.new('name' => "cluster_#{uri[0]}:#{uri[1]}", 'label' => "#{uri[0]}:#{uri[1]}")
      end

      @graph.each_vertex do |v|
        uri = URI.parse v.to_s
        subgraph = subgraphs[[uri.host, uri.port]]
        subgraph << make_node(v)
      end

      graph = RGL::DOT::Digraph.new
      subgraphs.values.each &graph.method(:<<)
      @graph.each_edge do |u, v|
        graph << make_edge(u, v)
      end

      graph
    end
  end
end
