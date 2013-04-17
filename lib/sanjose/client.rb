module Sanjose
  GCM_GATEWAY_URI = "https://android.googleapis.com/gcm/send"
  
  class Client
    attr_accessor :gcm_gateway_uri, :gcm_api_key
    
    def initialize
      @gcm_gateway_uri = GCM_GATEWAY_URI
      @gcm_api_key = ENV['GCM_API_KEY']
    end
    
    def push(notification)
      return if not notification or notification.sent?
              
      uri = connection_options_for_endpoint(:gateway)
      Connection.open(uri) do |connection|
        message = notification.message
        puts message
        
        # Need to put gcm api key in header and content length
        headers = {"Authorization" => "key=#{@gcm_api_key}",
                   "Content-type" => "application/json",
                   "Content-length" => "#{message.length}"}
        response = connection.post(uri.path, message, headers)
        notification.mark_as_sent!        
      end
    end
      
    private
    
      def connection_options_for_endpoint(endpoint = :gateway)
        uri = case endpoint
                when :gateway then URI(@gcm_gateway_uri)
                else
                  raise ArgumentError
              end        
      end
  end
end