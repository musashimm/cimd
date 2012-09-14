module CIMD

  class Connection
  
    attr_accessor :server
    attr_accessor :port
    attr_accessor :user_identity
    attr_accessor :password
    attr_accessor :keep_alive
    attr_accessor :packet_number
    attr_accessor :window_size
    attr_accessor :alpha_orig_address
  
    def initialize(server,port,user_identity,password,alpha_orig_address,window_size,keep_alive)
      @server = server
      @port = port
      @user_identity = user_identity
      @password = password
      @keep_alive = keep_alive
      @packet_number = 1
      @alpha_orig_address = alpha_orig_address
      @window_size = window_size
    end
  
    def to_s
      return sprintf "\n\n*** Connection object:\nServer: %s\n,Port: %s\n,User identity: %s\nPassword: %s\nKeep Alive: %3d\nAlpha Orig Address: %s\n Packet number: %d\n\n",@server,@port,@user_identity,@password,@keep_alive,@alpha_orig_address,@packet_number
    end
  
    def packet_number?
      return @packet_number
    end
  
    def packet_number!
      f = @packet_number
      (@packet_number += 2) > 255 ? @packet_number = 1 : @packet_number
      return f
    end
  
  end #connection

  class Parameter
    
    attr_accessor :code
    attr_accessor :value

    def initialize(code,value)
      @code = code
      @value = value
    end

    def to_s
      return sprintf "%03d:%s",@code,@value
    end

    def self.parse(data)
      fields = data.split(":")
      p = Parameter.new((fields[0]).to_i,fields[1])
      return p
    end

  end #parameter

  class Dcs

    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def set_value(value)
      @value = value.to_i
    end

    def coding_group
      return @value & 0xF0
    end

    def has_coding_group_zero?
      (@value & 0b11000000).zero?
    end

    def has_default_alphabet?
      value.zero?
    end

    def alphabet
      if has_coding_group_zero?
        return (@value & 0b00001100) >> 2
      else
        return 0
      end
    end

    def alphabet_set_UCS2
      value = 8
    end

  end #dcs

  class Message

    attr_accessor :operation_code
    attr_accessor :parameters
    attr_accessor :packet_number
    attr_accessor :checksum
    attr_accessor :dcs

    def initialize(operation_code)
      @operation_code = operation_code
      @packet_number = 1
      @parameters = Array.new
      @checksum = 0
      @dcs = Dcs.new(0)
    end

    def alphabet
      @dcs.alphabet
    end

    def has_alphabet_ucs2?
      @dcs.alphabet == ALPHABET_UCS2
    end

    def has_error?
      return has_parameter?(P_ERROR_CODE) ? true : false
    end

    def error
      return has_error? ? "(#{parameter_value(CIMD::P_ERROR_CODE)}) #{parameter_value(CIMD::P_ERROR_TEXT)}" : nil
    end

    def calc_checksum
      checksum = 0
      s = String.new
      s << STX
      s << (sprintf "%02d:%03d",@operation_code,@packet_number)
      s << TAB
      @parameters.each do |p|
        s << p.to_s
        s << TAB
      end

      s.each_byte do |b|
        checksum += b
        checksum &= 0xFF
      end
      return checksum
    end

    def add(parameter)
      @parameters.push(parameter)
    end

    def to_s
      s = sprintf "<STX>%02d:%03d<TAB>",@operation_code,@packet_number
      #add(Parameter.new(P_DATA_CODING_SCHEME,@dcs.value)) @operation_code == OP_SUBMIT
      @parameters.each do |p|
        s << p.to_s
        s << "<TAB>"
      end
      s << (sprintf "%02x",@checksum).upcase
      s << "<ETX> "
      s << CIMD::opcode_description(@operation_code)
      return s
    end

    def to_binary
      s = String.new
      s << STX
      s << (sprintf "%02d:%03d",@operation_code,@packet_number)
      s << TAB
      #add(Parameter.new(P_DATA_CODING_SCHEME,@dcs.value)) if @operation_code == OP_SUBMIT
      @parameters.each do |p|
        s << p.to_s
        s << TAB
      end
      s << (sprintf "%02x",calc_checksum)
      s << ETX
      return s
    end

    def is_binary?
      has_parameter?(P_USER_DATA_BINARY)
    end

    def self.parse(data)
      data.slice!(0)
      fields = data.split(TAB)
      header = fields[0].split(PARAM_SEP)
      operation_code = header[0].to_i
      m = Message.new(operation_code)
      m.packet_number = header[1].to_i
      fields.delete_at(0)
      m.checksum = (fields.delete_at(fields.size - 1)).hex.to_i
      fields.each do |p|
          m.parameters << Parameter.parse(p)
      end
      m.dcs.set_value(m.parameter_value(P_DATA_CODING_SCHEME)) if m.has_parameter?(P_DATA_CODING_SCHEME)
      return m
    end

    def parse_binary_data
      if has_alphabet_ucs2? and @operation_code == OP_DELIVERY_MESSAGE
        data = parameter_value(P_USER_DATA_BINARY)
        i = 0
        s = ""
        while i < data.length do
          s << data[i,2].hex
          i += 2
        end
        p = Parameter.new(P_USER_DATA,Iconv.iconv("UTF-8", "UCS-2BE",s).first)
        add(p)
      end
    end

    def has_parameter?(code)
      @parameters.each do |p|
        return true if p.code == code
      end
      return false
    end

    def parameter_value(code)
      @parameters.each do |p|
        return p.value if p.code == code
      end
      return nil
    end

  end # message

end # CIMD




