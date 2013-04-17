require 'net/http'

module Sanjose
  class Connection
    class << self
      def open(uri)
        return if uri == nil            
                
        connection = connection_for_uri(uri)
        connection.start
        
        yield connection
        
        connection.finish
      end
    end
    
    private
    
      def self.connection_for_uri(uri)
        connection = Net::HTTP.new(uri.host, uri.port)
        connection.use_ssl = uri.scheme == 'https'
        connection
      end
  end
end
