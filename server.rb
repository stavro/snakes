require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'erb'
require 'celluloid/autostart'
require 'oj'
require 'forwardable'
require 'securerandom'

require_relative 'lib/point'
require_relative 'lib/direction'
require_relative 'lib/world'
require_relative 'lib/snake'
require_relative 'lib/socket_listener'
require_relative 'lib/client'
require_relative 'lib/map'
require_relative 'lib/tournament'

class WebServer < Reel::Server::HTTP
  include Celluloid::Logger

  attr_reader :index_page

  def initialize(host = "127.0.0.1", port = 1234)
    info "[Server] WebServer starting on #{host}:#{port}"
    @index_page = ERB.new(File.read(File.expand_path("../views/index.html.erb", __FILE__)), nil, "-")
    super(host, port, &method(:on_connection))
  end

  def on_connection(connection)
    while request = connection.request
      if request.websocket?
        info "[Server] Received a WebSocket connection"
        connection.detach
        return route_websocket(request.websocket)
      else
        route_request connection, request
      end
    end
  end

  def route_request(connection, request)
    if request.url == "/"
      return render_index(connection)
    end

    info "[Server] 404 Not Found: #{request.path}"
    connection.respond :not_found, "Not found"
  end

  def route_websocket(socket)
    if socket.url == "/socket"
      Client.new(socket)
    else
      info "[Server] Received invalid WebSocket request for: #{socket.url}"
      socket.close
    end
  end

  def render_index(connection)
    info "200 OK: /"
    connection.respond :ok, index_page.result(binding)
  end
end

World.supervise_as :world
WebServer.supervise_as :web_server

sleep
