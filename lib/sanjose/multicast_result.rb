module Sanjose
  class MulticastResult
    attr_accessor :retry_multicast_ids
    attr_reader :success, :failure, :canonical_ids, :multicast_id, :results
    
    def initialize(options = {})
      @success = options[:success]
      @failure = options[:failure]
      @canonical_ids = options[:canonical_ids]
      @multicast_id = options[:multicast_id]      
      @results = []      
      @retry_multicast_ids = []
    end
    
    def add_result(result)
      @results << result
    end
    
  end
end