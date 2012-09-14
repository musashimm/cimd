require 'cimd'
require 'iconv'

describe CIMD do

  it "has constants" do
    CIMD::OP_LOGIN.should == 1
    CIMD::OP_LOGOUT.should == 2
    CIMD::OP_SUBMIT.should == 3
    CIMD::ALPHABET_BINARY.should == 8
  end

  context CIMD::Connection do

    let(:cn) { CIMD::Connection.new('server',1234,'user1','password1',nil,1,120) }
    let(:c) { CIMD::Connection.new('server',1234,'user1','password1','alpha',1,120) }

    it "returns connection object with nil alpha orig number" do
      cn.user_identity.should eq('user1')
      cn.password.should eq('password1')
      cn.server.should eq('server')
      cn.port.should eq(1234)
      cn.alpha_orig_address.should be_nil
      cn.window_size.should eq(1)
      cn.keep_alive.should eq(120)
    end

    it "returns connection object with not nil alpha orig number" do
      c.user_identity.should eq('user1')
      c.password.should eq('password1')
      c.alpha_orig_address.should eq('alpha')
    end
  
    it "returns first packet number" do
      c.packet_number?.should eq(1)
    end

    it "returns 10th packet number" do
      10.times { c.packet_number! }
      c.packet_number?.should eq(21)
    end

    it "returns 130th packet number" do
      130.times { c.packet_number! }
      c.packet_number?.should eq(5)
    end

    it "opcode description" do
      CIMD::opcode_description("as").should eq("(UNKNOWN)")
      CIMD::opcode_description(CIMD::OP_LOGIN).should eq("(OP_LOGIN)")
    end


  end # context CIMD::Connection

  context CIMD::Message do

    let(:cn) { CIMD::Connection.new('server',1234,'user1','password1',nil,1,120) }
    let(:c) { CIMD::Connection.new('server',1234,'user1','password1','alpha',1,120) }
    let(:lm) { CIMD::login_message(cn) }
    let(:lo) { CIMD::logout_message }
    let(:submitn) { CIMD::submit_text_message(cn,'1234567789','textn') }
    let(:submit) {CIMD::submit_text_message(c,'1234567789','text') }

    it "returns login message" do
      lm.has_parameter?(CIMD::P_USER_IDENTITY).should be_true
      lm.has_parameter?(CIMD::P_PASSWORD).should be_true
      lm.parameter_value(CIMD::P_USER_IDENTITY).should eq('user1')
      lm.parameter_value(CIMD::P_PASSWORD).should eq('password1')
      lm.has_parameter?(CIMD::P_DESTINATION_ADDRESS).should be_false
      lm.parameter_value(CIMD::P_DESTINATION_ADDRESS).should be_nil
    end

    it "returns logout message" do
      lo.parameters.size.should eq(0)
    end

    it "to_s" do
      submit.to_s.should eq("<STX>03:001<TAB>021:1234567789<TAB>033:text<TAB>027:alpha<TAB>00<ETX> (OP_SUBMIT)")
      submitn.to_s.should eq("<STX>03:001<TAB>021:1234567789<TAB>033:textn<TAB>00<ETX> (OP_SUBMIT)")
    end

    it "submit message with no alpha" do
      #puts submitn
      submitn.parameters.size.should eq(2)
      submitn.has_parameter?(CIMD::P_ALPHA_ORIG_ADDRESS).should be_false
    end

    it "submit message with alpha" do
      #puts submit
      submit.parameters.size.should eq(3)
      submit.has_parameter?(CIMD::P_ALPHA_ORIG_ADDRESS).should be_true
      submit.parameter_value(CIMD::P_ALPHA_ORIG_ADDRESS).should eq('alpha')
    end

    it "return confirmation frame" do
      submit.packet_number = 5
      m = CIMD::only_response_message(submit)
      m.packet_number.should eq(submit.packet_number)
      m.operation_code.should eq(submit.operation_code+50)
    end

    it "inserts packet number to message" do
      10.times { c.packet_number! }
      submit.packet_number = c.packet_number!
      submit.packet_number.should eq(21)
    end

    it "calculates checksum test" do
      m = CIMD::Message.new(CIMD::OP_GENERAL_ERROR_RESPONSE)
      m.packet_number = 1
      m.add(CIMD::Parameter.new(CIMD::P_ERROR_CODE,'2'))
      m.add(CIMD::Parameter.new(CIMD::P_ERROR_TEXT,'Syntax error'))
      sprintf("%02x",m.calc_checksum).upcase.should eq('03')
    end

    it "parses message" do
      s = ""
      s << CIMD::STX
      s << (sprintf("%02d:%03d\t",1,23))
      s << (sprintf("%03d:%s\t",11,'admin1'))
      s << (sprintf("%03d:%s\t",10,'jan'))
      s << "57"
      s << CIMD::ETX
      m = CIMD::Message.parse(s)
      m.operation_code.should eq(1)
      m.packet_number.should eq(23)
      m.parameter_value(CIMD::P_USER_IDENTITY).should eq('jan')
      m.parameter_value(CIMD::P_PASSWORD).should eq('admin1')
      sprintf("%02x",m.calc_checksum).upcase.should eq('57')
    end

    it "parses binary message" do
      s ="\00220:000\t021:48661001723\t023:48601130651\t060:120210100902\t034:0044006600760067006700720067006200760142006400660076007600660105\t052:0\t030:8\t1A\003"
      m = CIMD::Message.parse(s)
      sprintf("%02x",m.calc_checksum).upcase.should eq('1A')
      m.is_binary?.should be_true
      m.dcs.coding_group.should be_zero
      m.dcs.has_coding_group_zero?.should be_true
      m.alphabet.should eq(2)
      m.has_alphabet_ucs2?.should be_true
      m.parse_binary_data
      m.parameter_value(CIMD::P_USER_DATA).should match(/^D/)
    end

  end

  #context CIMD::Loop do
    #let(:loop) { CIMD::Loop.new({}) }

    #it ("create new loop instance") do
      #puts loop
    #end

  #end

end

