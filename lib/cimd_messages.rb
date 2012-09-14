module CIMD

  def self.login_message(connection)
    m = Message.new(OP_LOGIN)
    p_login = Parameter.new(P_USER_IDENTITY,connection.user_identity)
    p_password = Parameter.new(P_PASSWORD,connection.password)
    m.add(p_login)
    m.add(p_password)
    return m
  end
  
  def self.logout_message
    m = Message.new(OP_LOGOUT)
    return m
  end
  
  def self.submit_text_message(connection,msisdn,text)
    m = Message.new(OP_SUBMIT)
    p_msisdn = Parameter.new(P_DESTINATION_ADDRESS,msisdn)
    p_text = Parameter.new(P_USER_DATA,text)
    m.add(p_msisdn)
    m.add(p_text)
    unless connection.alpha_orig_address.nil?
      p_orig = Parameter.new(P_ALPHA_ORIG_ADDRESS,connection.alpha_orig_address)
      m.add(p_orig)
    end
    return m
  end
  
  def self.submit_binary_message(connection,msisdn,binary_text)
    m = Message.new(OP_SUBMIT)
    p_msisdn = Parameter.new(P_DESTINATION_ADDRESS,msisdn)
    p_text = Parameter.new(P_USER_DATA_BINARY,binary_text)
    p_dcs = Parameter.new(P_DATA_CODING_SCHEME,ALPHABET_BINARY)
    m.add(p_msisdn)
    m.add(p_text)
    m.add(p_dcs)
    unless connection.alpha_orig_address.nil?
      p_orig = Parameter.new(P_ALPHA_ORIG_ADDRESS,connection.alpha_orig_address)
      m.add(p_orig)
    end
    return m
  end
  
  def self.only_response_message(message)
    m = Message.new(message.operation_code + 50)
    m.packet_number = message.packet_number
    return m
  end
  
  def self.alive_message
    m = Message.new(OP_ALIVE)
    return m
  end

end
