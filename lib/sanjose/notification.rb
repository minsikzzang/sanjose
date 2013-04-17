require 'json'

module Sanjose
  class Notification
    attr_accessor :data, :collapse_key, :delay_when_idle, :time_to_live,
                  :dry_run, :restricted_package_name, :devices
    attr_reader :sent_at
    
    def initialize(options = {})
      # Required field
      # A string array with the list of devices (registration IDs) receiving 
      # the message. It must contain at least 1 and at most 1000 registration IDs.
      if !options[:devices]
        @devices = []
      else
        @devices = options[:devices]
      end
      
      # Optional fields
      # An arbitraru string (such as "Updates Available") that is used to 
      # collapse a group of like messages when the device is offline, so 
      # that only the last message gets sent to the client.
      @collapse_key = options[:collapse_key] 
      
      # If included, indicates that the message should not be sent immediately 
      # if the device is idle. 
      @delay_when_idle = options[:delay_when_idle]
      
      # How long (in seconds) the message should be kept on GCM storage if the 
      # device is offline. 
      @time_to_live = options[:time_to_live]
      
      # If included, allows developers to test their request without actually 
      # sending a message. Optional. The default value is false, and must be a 
      # JSON boolean.      
      @dry_run = options[:dry_run]
      
      # A string containing the package name of your application. When set, 
      # messages will only be sent to registration IDs that match the package 
      # name. 
      @restricted_package_name = options[:restricted_package_name]
      
      # A JSON object whose fields represents the key-value pairs of the message's 
      # payload data. There is no limit on the number of key/value pairs, though 
      # there is a limit on the total size of the message (4kb).
      @data = options[:data]
    end
    
    def add_device(device)
      @devices << device
    end
    
    def device_size
      @devices.length
    end
    
    def message
      # plan-text format
      # 'registration_id=APA91bH35MqYza3xfc2hfag6Rr8VQPSOmi2nrUOPABlFwowfVMZNHaBGBpx-zQ7nuv9qzCEosepUMPKyOrVn0UncZMa__E2sWuM2Q53fjJ5loqIY1QKCza3MkxAu1rvyhhzJP3meEqpmv-kjBuRTeWe_ysRUICupE-awrK1eiStmmm2Y_VBBSs4'
      # json format
      # '{"registration_ids":["APA91bH35MqYza3xfc2hfag6Rr8VQPSOmi2nrUOPABlFwowfVMZNHaBGBpx-zQ7nuv9qzCEosepUMPKyOrVn0UncZMa__E2sWuM2Q53fjJ5loqIY1QKCza3MkxAu1rvyhhzJP3meEqpmv-kjBuRTeWe_ysRUICupE-awrK1eiStmmm2Y_VBBSs4","APA91bHAX-Owu0Ulm5XubHs7BYy6a4O87Gk8-2JOW3eJ2TauVzWsB0d4yCxjzxMXl40elIIwG3E0Lpvd1_5xGldZm64UO4fqC0RNpvGWKUSr7hMNhavRS8w2NS2XUwYsluysVaXZU0rvmq0zSCH6JHGZiqd0qlUsmg"]}'
      
      json = {}
      if @devices.empty?
        raise ArgumentError 'devices cannot be empty'
      else
        json['registration_ids'] = @devices
      end
      
      if @collapse_key
        json['collapse_key'] = @collapse_key
      end
      if @delay_when_idle
        json['delay_when_idle'] = @delay_when_idle
      end
      
      if @time_to_live
        json['time_to_live'] = @time_to_live
      end
      
      if @data
        json['data'] = @data
      end
      
      if @restricted_package_name
        json['restricted_package_name'] = @restricted_package_name
      end
      
      if @dry_run
        json['dry_run'] = @dry_run
      end
      
      json.to_json
    end
    
    def mark_as_sent!
      @sent_at = Time.now
    end

    def sent?
      !!@sent_at
    end
  end
end