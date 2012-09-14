#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require 'cimd'
require 'thor'

module CIMD

  def self.start_eventmachine(conn,messages,options)
    EventMachine.run do
      Signal.trap("INT") { CIMD::Loop.logout_request }
      Signal.trap("TERM") { CIMD::Loop.logout_request }
      EventMachine.connect conn.server, conn.port, CIMD::Loop do |c|
        c.messages = messages
        c.conn = conn
        c.options = options
      end
    end
  end

  class MyCLI < Thor

    desc "sendsms", "Sends text SMS to MSISDN number"
    option :server, :required => true,:desc => "Address of SMSC server (can be DNS name)"
    option :port, :desc => "Port number for CIMD protocol",:default => 9971
    option :user_identity, :required => true,:desc => "Username of CIMD account"
    option :password, :required => true,:desc => "Password for CIMD account USERNAME"
    option :message, :desc => "Message to be send",:default=>"SMS test message"
    option :msisdn, :required => true,:desc => "MSISDN number to be send"
    option :alpha_orig_address, :desc => "Identity of sender",:default => "Sms Service"
    def sendsms()
      puts "Sending sms message: #{options[:message]} to #{options[:msisdn]}"
      conn = CIMD::Connection.new(options[:server],options[:port],options[:user_identity],options[:password],options[:alpha_orig_address],1,60)
      messages = EM::Queue.new
      messages.push(CIMD::login_message(conn))
      messages.push(CIMD::submit_text_message(conn,options[:msisdn],options[:message]))
      messages.push(CIMD::logout_message)
      CIMD::start_eventmachine(conn,messages,{})
    end

    desc "receivesms", "Receives smses and sends echo"
    long_desc <<-LONGDESC
    `cimd_cli.rb receivesms` receives smses endlessly. If You want to stop
    reciving just press ^C.
    LONGDESC
    option :server, :required => true,:desc => "Address of SMSC server (can be DNS name)"
    option :port, :desc => "Port number for CIMD protocol",:default => 9971
    option :user_identity, :required => true,:desc => "Username of CIMD account"
    option :password, :required => true,:desc => "Password for CIMD account USERNAME"
    option :message, :desc => "Message to be send",:default=>"SMS test message"
    option :msisdn, :required => true,:desc => "MSISDN number to be send"
    option :alpha_orig_address, :desc => "Identity of sender",:default => "Sms Service"
    def receivesms()
      puts "Start receiving"
      conn = CIMD::Connection.new(options[:server],options[:port],options[:user_identity],options[:password],options[:alpha_orig_address],1,60)
      messages = EM::Queue.new
      messages.push(CIMD::login_message(conn))
      CIMD::start_eventmachine(conn,messages,{})
    end

  end

end

CIMD::MyCLI.start(ARGV)




