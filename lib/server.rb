require 'rack'
require 'sinatra'
require 'webrick'

ENV['RACK_ENV'] = 'production' 

module SSLCheck
  class TheServer < Sinatra::Base
    get '/' do
      "TEST"
    end
  end

  class Server
    def self.run
      # Server options
      opts = {
           :Port               => PORT, 
           :Logger             => WEBrick::Log::new(STDOUT, WEBrick::Log::DEBUG),
           :ServerType         => WEBrick::SimpleServer, #WEBrick::Daemon,
           :SSLEnable          => SSL_ENABLE,
      }
      Rack::Handler::WEBrick.run(SSLCheck::TheServer, opts) do |server|
        [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
      end
    end
  end
end

#PORT=8000
#SSL_ENABLE=false
#SSLCheck::Server.run
