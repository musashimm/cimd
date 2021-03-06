module CIMD

  STX = 0x02
  ETX = 0x03
  TAB = "\t"
  CC = 0xFF
  PARAM_SEP = ":"

  # OP - OPERATION CODES
  OP_LOGIN = 1
  OP_LOGOUT = 2
  OP_SUBMIT= 3
  OP_ENQUIRE_MESSAGE_STATUS = 4
  OP_DELIVERY_REQUEST = 5
  OP_CANCEL_MESSAGE = 6
  OP_SET = 8
  OP_GET = 9
  OP_DELIVERY_MESSAGE = 20
  OP_DELIVERY_STATUS_REPORT = 23
  OP_ALIVE = 40
  OP_LOGIN_RESPONSE = 51
  OP_LOGOUT_RESPONSE = 52
  OP_SUBMIT_RESPONSE = 53
  OP_ENQUIRE_MESSAGE_STATUS_RESPONSE = 54
  OP_DELIVERY_REQUEST_RESPONSE = 55
  OP_CANCEL_MESSAGE_RESPONSE = 56
  OP_SET_RESPONSE = 58
  OP_GET_RESPONSE = 59
  OP_DELIVERY_MESSAGE_RESPONSE = 70
  OP_DELIVERY_STATUS_REPORT_RESPONSE = 73
  OP_ALIVE_RESPONSE = 90
  OP_GENERAL_ERROR_RESPONSE = 98
  OP_NACK = 99

  def self.opcode_description(op_code)
    descs = {
      OP_LOGIN => "OP_LOGIN",
      OP_LOGOUT => "OP_LOGOUT",
      OP_SUBMIT=> "OP_SUBMIT",
      OP_ENQUIRE_MESSAGE_STATUS => "OP_ENQUIRE_MESSAGE_STATUS",
      OP_DELIVERY_REQUEST => "OP_DELIVERY_REQUEST",
      OP_CANCEL_MESSAGE => "OP_CANCEL_MESSAGE",
      OP_SET => "OP_SET",
      OP_GET => "OP_GET",
      OP_DELIVERY_MESSAGE => "OP_DELIVERY_MESSAGE",
      OP_DELIVERY_STATUS_REPORT => "OP_DELIVERY_STATUS_REPORT",
      OP_ALIVE => "OP_ALIVE",
      OP_LOGIN_RESPONSE => "OP_LOGIN_RESPONSE",
      OP_LOGOUT_RESPONSE => "OP_LOGOUT_RESPONSE",
      OP_SUBMIT_RESPONSE => "OP_SUBMIT_RESPONSE",
      OP_ENQUIRE_MESSAGE_STATUS_RESPONSE => "OP_ENQUIRE_MESSAGE_STATUS_RESPONSE",
      OP_DELIVERY_REQUEST_RESPONSE => "OP_DELIVERY_REQUEST_RESPONSE",
      OP_CANCEL_MESSAGE_RESPONSE => "OP_CANCEL_MESSAGE_RESPONSE",
      OP_SET_RESPONSE => "OP_SET_RESPONSE",
      OP_GET_RESPONSE => "OP_GET_RESPONSE",
      OP_DELIVERY_MESSAGE_RESPONSE => "OP_DELIVERY_MESSAGE_RESPONSE",
      OP_DELIVERY_STATUS_REPORT_RESPONSE => "OP_DELIVERY_STATUS_REPORT_RESPONSE",
      OP_ALIVE_RESPONSE => "OP_ALIVE_RESPONSE",
      OP_GENERAL_ERROR_RESPONSE => "OP_GENERAL_ERROR_RESPONSE",
      OP_NACK => "",
    }
    return descs.has_key?(op_code) ? "(#{descs[op_code]})" : "(UNKNOWN)"
  end
  
  # P - PARAMETER
  P_USER_IDENTITY = 10
  P_PASSWORD = 11
  P_SUBADDR = 12
  P_WINDOW_SIZE = 19
  P_DESTINATION_ADDRESS = 21
  P_ORIGINATOR_ADDRESS = 23
  P_ALPHA_ORIG_ADDRESS = 27
  P_DATA_CODING_SCHEME = 30
  P_USER_DATA_HEADER = 32
  P_USER_DATA = 33
  P_USER_DATA_BINARY = 34
  P_PROTOCOL_IDENTIFIER = 52
  P_SERVICE_CENTRE_TIME_STAMP = 60
  P_ERROR_CODE = 900
  P_ERROR_TEXT = 901
  
  DEFAULT_WINDOW_SIZE = 1
  DEFAULT_KEEP_ALIVE = 60
  
  ALPHABET_DEFAULT = 0
  ALPHABET_8BIT = 1
  ALPHABET_UCS2 = 2
  ALPHABET_RESERVED = 3
  
  ALPHABET_BINARY = 8
end
