require 'nmap/xml'

# remove later
require 'logger'
LOG = Logger.new(STDOUT)

module SSLCheck
  class Ciphers
   
    def self.verify
      urls         = {
                        'corporate' => {
                          'url' => 'srcclr.com',
                          'port'=>'443'
                        }
                      }
      get_ciphers(urls)
      read_ciphers
    
    end
 
    def self.get_ciphers(urls)
      @xml_paths = Hash.new
      urls.each do |env, data|
        url   = data['url']
        port  = data['port']
        LOG.debug "Verifying #{env} - #{url}:#{port}"
 
        IO.popen("nmap -oX ciphers/#{env}.xml --script ssl-enum-ciphers -p #{port} #{url}") do |output|
          LOG.info output.readlines
        end
        @xml_paths[env] = "ciphers/#{env}.xml"
      end
      @xml_paths 
    end

    def self.read_ciphers
      @xml_paths.each do |env, path|
        Nmap::XML.new(path) do |xml|
          xml.each_host do |host|
            LOG.info "[#{host.ip}]"

            host.scripts.each do |name,output|
              output.each_line { |line| LOG.info "  #{line}" }
            end

            host.each_port do |port|
              LOG.info "  [#{port.number}/#{port.protocol}]"

              port.scripts.each do |name,output|
                LOG.info "    [#{name}]"

                output.each_line { |line| LOG.info "      #{line}" }
              end
            end
          end
        end
      end
    end
  end
end
    
SSLCheck::Ciphers.verify
