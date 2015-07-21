require 'rubygems'
require 'rack'
require 'sinatra'
require 'webrick'

ENV['RACK_ENV'] = 'production' 

class TheServer < Sinatra::Base
  get '/' do
    "TEST"
  end
end

# Init the server
module SSLCheck
  class Server
    def self.run
      # Server options
      opts = {
           :Port               => PORT, 
           :Logger             => WEBrick::Log::new(STDOUT, WEBrick::Log::DEBUG),
           :ServerType         => WEBrick::SimpleServer, #WEBrick::Daemon,
           :SSLEnable          => SSL_ENABLE,
      }
      Rack::Handler::WEBrick.run(TheServer, opts) do |server|
        [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
      end
    end
  end
end

