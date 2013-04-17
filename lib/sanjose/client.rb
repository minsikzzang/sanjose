module Sanjose
  GCM_GATEWAY_URI = "https://android.googleapis.com/gcm/send"
  MULTICAST_SIZE = 1000
  TOKEN_CANONICAL_REG_ID = 'registration_id'
  JSON_SUCCESS = 'success'
  JSON_FAILURE ='failure'
  JSON_CANONICAL_IDS = 'canonical_ids'
  JSON_MULTICAST_ID = 'multicast_id'
  JSON_RESULTS = 'results'
  JSON_MESSAGE_ID = 'message_id'
  JSON_ERROR = 'error'
  ERROR_UNAVAILABLE = "Unavailable";
  
  # Initial delay before first retry
  BACKOFF_INITIAL_DELAY = 1000
  
  # Maximum delay before a retry.
  MAX_BACKOFF_DELAY = 1024000
  
  class Client
    attr_accessor :gcm_gateway_uri, :gcm_api_key
    
    def initialize
      @gcm_gateway_uri = GCM_GATEWAY_URI
      @gcm_api_key = ENV['GCM_API_KEY']
    end
    
    def push(notification, retries = 5)
      return if not notification or notification.sent?
      
      attempt = 0
      try_again = true
      muticast_ids = []
      results = {}
      unsent_reg_ids = notification.devices
      backoff = BACKOFF_INITIAL_DELAY
      
      while try_again do
        attempt += 1
        multicast_result = push_no_retry(notification, 
          connection_options_for_endpoint(:gateway), unsent_reg_ids)
        
        if multicast_result
          muticast_ids << multicast_result.multicast_id
          unsent_reg_ids = update_status(unsent_reg_ids, results, multicast_result)
        end
        
        try_again = !unsent_reg_ids.empty? and attempt <= retries
        
        if try_again
          sleep_time = backoff / 2 + rand(backoff)
          sleep(sleep_time / 1000)
          if 2 * backoff < MAX_BACKOFF_DELAY
            backoff *= 2
          end
        end       
      end    
      
      # calculate summary
      success = 0
      failure = 0
      canonical_ids = 0
      
      results.values.each do |result|
        if result.message_id
          success += 1
          if result.canonical_reg_id
            canonical_ids += 1
          end
        else
          failure += 1
        end
      end
        
      # build a new object with the overall result
      multicast_id = muticast_ids.pop(0)
      builder = MulticastResult.new(
        :success => success, 
        :failure => failure, 
        :canonical_ids => canonical_ids,
        :multicast_id => multicast_id)
      builder.retry_multicast_ids = muticast_ids
      
      # add results, in the same order as the input
      notification.devices.each do |device|
        builder.add_result(results[device])
      end
      
      builder
    end
      
    private
      def update_status(unsent_reg_ids, all_results, multicast_result)
        results = multicast_result.results
        if results.length != unsent_reg_ids.length
          # should never heppan, unless there is a flaw in the algorithm
          raise RuntimeError 
            "internal error: sizes do not match. current_results: #{results}; unsent_reg_ids: #{unsent_reg_ids}"
        end
        
        new_unsent_reg_ids = []
        i = 0
        unsent_reg_ids.each do |reg_id|
          result = results.at(i)
          all_results[reg_id] = result
          i += 1
          if result.error and result.error == ERROR_UNAVAILABLE
            new_unsent_reg_ids << reg_id
          end
        end
        
        new_unsent_reg_ids        
      end
      
      def push_no_retry(notification, uri, reg_ids)        
        multicast_result = nil
        messages = notification.clone
        messages.devices = reg_ids
        
        Connection.open(uri) do |connection|
          message = messages.message

          # Need to put gcm api keyand content length in header 
          headers = {"Authorization" => "key=#{@gcm_api_key}",
                     "Content-type" => "application/json"}
          response = connection.post(uri.path, message, headers)          
          return nil if response.code != "200"            
          
          json = JSON.parse(response.body)          
          multicast_result = MulticastResult.new(
            :success => json[JSON_SUCCESS], 
            :failure => json[JSON_FAILURE], 
            :canonical_ids => json[JSON_CANONICAL_IDS],
            :multicast_id => json[JSON_MULTICAST_ID])
          results = json[JSON_RESULTS]
          results.each do |result|
            multicast_result.add_result(
              Result.new(:message_id => result[JSON_MESSAGE_ID],
                :canonical_reg_id => result[TOKEN_CANONICAL_REG_ID],
                :error => result[JSON_ERROR]))
          end
        end
        multicast_result
      end
      
      def connection_options_for_endpoint(endpoint = :gateway)
        uri = case endpoint
                when :gateway then URI(@gcm_gateway_uri)
                else
                  raise ArgumentError
              end        
      end
  end
end