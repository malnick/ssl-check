#!/bin/env ruby

begin
  
  require 'rubygems'
  require 'logger'
  require 'json'
  require 'yaml'
  require 'optparse'
  require 'git'
  require 'fileutils'
  require 'net/http'
  require 'csv'

  # Require all my libs
  library_files = Dir[File.join(File.dirname(__FILE__), "*.rb")].sort
  library_files.each do |f|
    require f
  end

rescue Exception => e
  
  puts "Failure during requires..."
  puts e.message

end

begin 
  LOG = Logger.new(STDOUT) #Logger.new(File.expand_path(File.dirname(__FILE__)) + '/../logs/versionctl.log')
  LOG.info "Starting Versionctl..."
  config_path = ENV['VERSIONCTL_CONFIG_PATH'] ||  File.expand_path(File.dirname(__FILE__)) + '/../ext/versionctl.yaml' 
  CONFIG = Versionctl::Options.initialize(config_path)
rescue Exception => e
  puts e.backtrace
  puts e.message
end

