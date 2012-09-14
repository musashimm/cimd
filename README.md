CIMD
======

Overview
--------

Classes and binaries to handle SMS Cimd protocol.

Usage
-----

### cimd_cli.rb receivesms ###
`cimd_cli.rb receivesms` receives smses endlessly. If You want to stop reciving just press ^C.

    cimd_cli.rb receivesms --msisdn=MSISDN --password=PASSWORD --server=SERVER --user-identity=USER_IDENTITY

    Options:
      --server=SERVER                            # Address of SMSC server (can be DNS name)
      [--port=PORT]                              # Port number for CIMD protocol
                                                 # Default: 9971
      --user-identity=USER_IDENTITY              # Username of CIMD account
      --password=PASSWORD                        # Password for CIMD account USERNAME
      [--message=MESSAGE]                        # Message to be send
                                                 # Default: SMS test message
      --msisdn=MSISDN                            # MSISDN number to be send
      [--alpha-orig-address=ALPHA_ORIG_ADDRESS]  # Identity of sender
                                                 # Default: Sms Service
### cimd_cli.rb sendsms ###
`cimd_cli.rb sendsms` sends text SMS to MSISDN number

    cimd_cli.rb sendsms --msisdn=MSISDN --password=PASSWORD --server=SERVER --user-identity=USER_IDENTITY

    Options:
        --server=SERVER                            # Address of SMSC server (can be DNS name)
        [--port=PORT]                              # Port number for CIMD protocol
                                                   # Default: 9971
        --user-identity=USER_IDENTITY              # Username of CIMD account
        --password=PASSWORD                        # Password for CIMD account USERNAME
        [--message=MESSAGE]                        # Message to be send
                                                   # Default: SMS test message
        --msisdn=MSISDN                            # MSISDN number to be send
        [--alpha-orig-address=ALPHA_ORIG_ADDRESS]  # Identity of sender
                                                   # Default: Sms Service

    
