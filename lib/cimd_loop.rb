# -*- encoding: utf-8 -*-
require 'rubygems'
require 'eventmachine'
require 'cimd'

module CIMD

  class Loop < EventMachine::Connection
  
    @@logout_request = false
  
    STATE=[:not_connected,:connected,:banner_received,:ready_to_send,:suspend]
    MAX_NO_ACTIVITY_TIME = 180
    attr_accessor :state
    attr_accessor :messages
    attr_accessor :conn
    attr_accessor :keep_alive_counter
    attr_accessor :no_activity_counter
    attr_accessor :options
    attr_accessor :logfile
    attr_accessor :debug

    def to_log(message)
      #puts @debug
      #puts @logfile
      puts "#{Time.now.strftime("%Y-%m-%d/%H:%M:%S")} #{message}"
      #puts message if @debug
      #@logfile.puts message if @logfile
      $stdout.flush
    end
  
    def change_state(new_state)
      if @state != new_state
        to_log("#### Transition: #{@state.to_s} ==> #{new_state.to_s} (no_act:#{ Time.now.tv_sec - @no_activity_counter}, keep:#{Time.now.tv_sec - @keep_alive_counter}, queue:#{@messages.size})")
        @state = new_state
      end
    end
   
    def self.logout_request
      @@logout_request = true
    end
    
    def initialize
      @state = :not_connected
      @debug = false
      @log = nil
      @keep_alive_counter = Time.now.tv_sec
      @no_activity_counter = Time.now.tv_sec
      #@debug = true if @options[:debug]
      #begin
      #  @log = File.new("ss", "w") if options[:logfile]
      #rescue Exception => e
      #  puts e.to_s
      #  exit
      #end
    end
  
    def post_init
      
      @timer = EM.add_periodic_timer(1) do
  
      if @@logout_request == true 
        change_state(:logout_request)
        @@logout_request = false
      end
  
      change_state(:alive) if Time.now.tv_sec - @keep_alive_counter > @conn.keep_alive
      change_state(:no_activity) if Time.now.tv_sec - @no_activity_counter > MAX_NO_ACTIVITY_TIME
  
      #puts "No act:#{ Time.now.tv_sec - @no_activity_counter} Keep:#{Time.now.tv_sec - @keep_alive_counter} Queue: #{@messages.size}"
      case @state
        when :banner_received
          change_state(:login_request)
          @messages.pop{ |message|  sending_message(message)}
        when :login_sucessfull
          change_state(:ready_to_send)
        when :ready_to_send
          change_state(:suspend)
          @messages.pop{ |message|  sending_message(message)}
        when :no_activity,:logout_done
          close_connection
        when :alive
          change_state(:suspend)
          to_log("<<<< #{CIMD::alive_message}")
          sending_message(CIMD::alive_message)
        when :logout_request
          @messages = EM::Queue.new
          to_log("<<<< #{CIMD::logout_message}")
          messages.push(CIMD::logout_message);
          change_state(:ready_to_send)
        when :suspend
          #puts "Suspend"
        end
      end
  
    end # post_init
    
    def sending_message(message)
      message.packet_number = @conn.packet_number!
      to_log("<<<< #{message.to_s}")
      send_data message.to_binary
      @keep_alive_counter = Time.now.tv_sec
    end
  
    def sending_response_message(message)
      m = CIMD::only_response_message(message)
      to_log("<<<< #{m.to_s}")
      send_data m.to_binary
    end
    
    def connection_completed
      change_state(:connected)
    end
  
    def receive_data(data)
    #puts "Received plain data: #{data}"
  
      case data
        when /CIMD2-A/
          change_state(:banner_received)
        else
      
          (@buffer ||= BufferedTokenizer.new("\003")).extract(data).each do |line|
          message = Message.parse(line)
      
          to_log(">>>> #{message.to_s}")
          # sprawdzic checsum
          if message.is_binary?
            message.parse_binary_data
            to_log("**** Decoded binary: #{message.to_s}")
          end
          @no_activity_counter = Time.now.tv_sec
      
          case message.operation_code
            when CIMD::OP_LOGIN_RESPONSE
              if message.has_error?
                to_log("!!!! Error: #{message.error}")
                close_connection
              else
                change_state(:login_sucessfull)
              end
            when CIMD::OP_SUBMIT_RESPONSE
              if message.has_error?
                to_log("!!!! Error: #{message.error}")
              end
              change_state(:ready_to_send)
            when CIMD::OP_DELIVERY_STATUS_REPORT
              sending_response_message(message)
            when CIMD::OP_DELIVERY_MESSAGE
              sending_response_message(message)
              messages.push(CIMD::submit_text_message(@conn,message.parameter_value(CIMD::P_ORIGINATOR_ADDRESS),message.parameter_value(CIMD::P_USER_DATA)))
            when CIMD::OP_LOGOUT_RESPONSE
              change_state(:logout_done)
            when CIMD::OP_ALIVE_RESPONSE
            when CIMD::OP_GENERAL_ERROR_RESPONSE
              to_log("!!!! Error: #{message.error}")
              close_connection
          else
            to_log("???? Unknown message type: #{data}")
          end # case message.operation_code
        end
      end # case data
    end # receive_data
    
    def unbind
      @logfile.close unless @logfile.nil?
      change_state(:not_connected)
      EventMachine.stop_event_loop
    end
    
  end # class Loop

end # module CIMD
