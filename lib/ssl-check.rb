#!/bin/env ruby

begin
  
  require 'rubygems'
  require 'logger'
  require 'json'
  require 'yaml'
  require 'fileutils'
  require 'net/http'
  require_relative './ssl-check/server'
  
  # DONT DO THIS
  # Require all my libs
  #library_files = Dir[File.join(File.dirname(__FILE__), "*.rb")].sort
  #library_files.each do |f|
  #  require f
  #end

rescue Exception => e
  
  puts "Failure during requires..."
  puts e.message

end

begin 
  # Set logging for STDOUT so this works fine in Docker
  LOG = Logger.new(STDOUT)
  LOG.info "##### Starting SSL Check #####"
  
  # Generate our baseline configuration and export static vars
  config_path = ENV['SSL_CHECK_CONFIG_PATH'] ||  File.expand_path(File.dirname(__FILE__)) + '/../ext/ssl-check.yaml' 
  CONFIG      = SSLCheck::Options.initialize(config_path)
  PORT        = CONFIG[:ssl_check_port]
  SSL_ENABLE  = CONFIG[:ssl_check_use_ssl]

  SSLCheck::Server.run

rescue Exception => e
  puts e.backtrace
  puts e.message
end

