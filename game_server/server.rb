require 'rubygems'
require 'bundler/setup'
require 'reel'
require 'digest'
require 'erb'
require 'multi_json'
require 'mongoid'
require 'celluloid/autostart'
require 'forwardable'
require 'securerandom'
require 'encryptor'
require 'mongoid'
require 'pry'

require_relative 'lib/point'
require_relative 'lib/direction'
require_relative 'lib/world'
require_relative 'lib/snake'
require_relative 'lib/socket_listener'
require_relative 'lib/client'
require_relative 'lib/map'
require_relative 'lib/tournament'

def environment
  ENV["REEL_ENV"] ||= 'development'
  ENV["REEL_ENV"].to_sym
end

Mongoid.load!(File.join(File.dirname(__FILE__), '../shared/mongoid.yml'), environment)
require_relative "../shared/models/user"
require_relative 'lib/models/user'

class WebServer < Reel::Server
  include Celluloid::Logger

  def initialize
    host = ARGV[ARGV.find_index('-h') + 1] rescue "127.0.0.1"
    port = ARGV[ARGV.find_index('-p') + 1] rescue 1234

    info "[Server] WebServer starting on #{host}:#{port}"
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
end

World.supervise_as :world
WebServer.supervise_as :web_server

sleep
