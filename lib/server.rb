require 'rubygems'
require 'rack'
require 'sinatra'
require 'webrick'
require 'logger'
require File.expand_path(File.dirname(__FILE__)) + '/versionctl'

# Reset some envs
ENV['HOME']     = '/root'
ENV['PATH']     = '/sbin:/usr/sbin:/bin:/usr/bin:/opt/puppet/bin'
ENV['RACK_ENV'] = 'production' 

# Server options
opts = {
     :Port               => '8000',
     :Logger             => WEBrick::Log::new(STDOUT, WEBrick::Log::DEBUG),
     :ServerType         => WEBrick::SimpleServer, #WEBrick::Daemon,
     :SSLEnable          => false,
}

class Server < Sinatra::Base

  get '/' do
    begin
      LOG.info ("##### GET / #####")
      erb :index
      
      # Get Local Versions
      @puppetversions = Versionctl::PuppetVersions.getversions
      @puppetversions.each do |k,v|
        LOG.info "#{k}: #{v}"
      end

      # Per env get running veresions
      runningversions  = Hash.new
      environments     = CONFIG[:haproxys]
      
      environments.each do |e,d|
        LOG.info "##### Getting Versions in #{e} #####"
        runningversions[e]  = Hash.new
        stats               = "#{d['host']}:#{d['port']}/#{d['stats']}"
        hap_pw              = d['pw']
        hap_user            = d['user']

        # Parse running versions
        init            = Versionctl::RunningVersions.new
        init.stats_url  = stats
        init.hap_pw     = hap_pw
        init.hap_user   = hap_user
        versions        = init.parse
        
        # Create a hash per environment of env[srv] = version
        versions.each do |k,v|
          runningversions[e][k] = v
        end
      end
      @runningversions = runningversions

      # Color the data
      @colored_envs = Hash.new
      runningversions.each do |env, data|
        @colored_envs[env] = Hash.new
        colors = Versionctl::Color.new(@puppetversions, env)
        colors.runningversions = data 
        colors.colorize.each do |service, color|
          @colored_envs[env][service] = color
        end
      end
      
      LOG.info "RUNNINGVERSIONS"
      LOG.info @runningversions
      LOG.info "COLORED ENVS" 
      LOG.info @colored_envs

      erb :index
    rescue Exception => e
      LOG.info (e.message)
      LOG.info (e.backtrace)
    end
  end
	
  not_found do
		halt 404, 'Not found.'
	end
end

Rack::Handler::WEBrick.run(Server, opts) do |server|
	[:INT, :TERM].each { |sig| trap(sig) { server.stop } }
end

