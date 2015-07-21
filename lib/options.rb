module SSLCheck 
  class Options
    
    def self.initialize(config_path)
      
      # Temp and instance vars for config
      config_file = Hash.new
      @config     = Hash.new

      unless File.exists? config_path
        abort LOG.error "Config file not found! Please make sure #{config_path} exists."
      end

      LOG.info "##### Configuration #####"
      file = YAML.load(File.open(config_path, 'r')) 
      file.each do |k,v|
        config_file[k] = v
      end
      
      # Configuration
      @config[:urls]                 = config_file['urls']                    || abort LOG.error "Must pass 'urls' in #{config_path}" 
      @config[:ssl_check_port]       = ENV['SSL_CHECK_PORT']                  || config_file['ssl_check_config']['port'] 
      @config[:ssl_check_use_ssl]    = ENV['SSL_CHECK_USE_SSL']               || config_file['ssl_check_config']['ssl'] 
      @config[:on_failure_pagerduty] = ENV['SSL_CHECK_ON_FAILURE_PAGERDUTY']  || config_file['on_failure']['pager_duty']
      @config[:on_failure_slack      = ENV['SSL_CHECK_ON_FAILURE_SLACK']      || config_file['on_failure']['slack'] 
    
      @config.each do |k,v|
        LOG.info("#{k}: #{v}")
      end
      @config
    end
  end
end
