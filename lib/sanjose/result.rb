module Sanjose
  class Result
    attr_reader :message_id, :canonical_reg_id, :error
    
    def initialize(options = {})
      @message_id = options[:message_id]
      @canonical_reg_id = options[:canonical_reg_id]
      @error = options[:error]
    end
  end
end