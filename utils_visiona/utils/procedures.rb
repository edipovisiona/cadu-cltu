module Utils_visiona

  HK_PACKET_SUFFIX = "_HK_PACKET"
  COMMAND_COUNTER_ITEM_NAME = "COMMAND_COUNTER"
  COMMAND_ERROR_COUNTER_ITEM_NAME = "COMMAND_ERROR_COUNTER"

  # This function gets HK telemetry packet from a given target_name
  # Note: For this to work, telemetry must be in format TARGETNAME_HK_PACKET
  def target_hk_enabled?(target_name, timeout = 10)

    counter = get_tlm_cnt("#{target_name.upcase}", "#{target_name.upcase + HK_PACKET_SUFFIX}")
    wait_check_expression("get_tlm_cnt(\"#{target_name.upcase}\", \"#{target_name.upcase + HK_PACKET_SUFFIX}\") > #{counter}", timeout) 
  end

  # This function will validate a command sent using the target's accepted command counter
  # This function relies on target's HK TLM
  # Target must have exactly names in hk tlm packet in order to work
  def send_validated_cmd(target_name, command, timeout = DEFAULT_TIMEOUT, shouldSuccess:true)

    # Suppose the target_name is always upcase
    target_name = target_name.upcase

    # Verify if new HK Packets are on the way. Get updated command counter
    counter = get_tlm_cnt("#{target_name}", "#{target_name + HK_PACKET_SUFFIX}")
    wait_check_expression("get_tlm_cnt(\"#{target_name}\", \"#{target_name + HK_PACKET_SUFFIX}\") > #{counter}", timeout)

    command_counter = tlm("#{target_name} #{target_name + HK_PACKET_SUFFIX} #{COMMAND_COUNTER_ITEM_NAME}")
    cmd("#{target_name} #{command}")

    validator = shouldSuccess ? command_counter+1 : command_counter
    wait_check_expression("tlm(\"#{target_name} #{target_name + HK_PACKET_SUFFIX} #{COMMAND_COUNTER_ITEM_NAME}\") == #{validator}", timeout)
  end

  # This function specify how long a file transaction should performn
  def calculateWaitTime(fileSize, link)

    # fileSize should be in bytes, so...
    # Hypotetical 50% of max performance here.
    perf = 0.5
    return (fileSize/((link*perf).to_i<<7).to_f).ceil*2
  end

  # This is a specific function that verifies if TO is available.
  # If not, this function does enable it.
  def enable_TO(ip, destport, routemask, ifiledesc, timeout)

    begin

      puts "Verifying if TO is enable"
      target_hk_enabled?("TO")
    rescue

      puts "TO not enable. Enabling it now!"
      cmd("TO TO_ENABLE_OUTPUT with IP \"#{ip}\", DESTPORT #{destport}, ROUTEMASK #{routemask}, IFILEDESC #{ifiledesc}")
      target_hk_enabled?("TO")
    end
  end

  # This function return the minimal amount of PDUS that will be transfered for a given
  # file. fileSize must be in kilobytes.
  def PDUS?(pdu_size, fileSize)

    return ((fileSize<<10)/pdu_size).ceil
  end

  def appendFile(fileName, text)

    return if (text.nil? || fileName.nil?)
    File.open(fileName, 'a+') {|file| file.write(text)}
  end

  # This function aims to Load, Validate and Active a Double-Buffered (check) Table
  def lva_table(file_name, table_name)

    default_wait = defined?(DEFAULT_TIMEOUT) ? DEFAULT_TIMEOUT : 10

    # Load Table
    send_validated_cmd("CFE_TBL", "CFE_TBL_LOAD with LOADFILENAME #{file_name}")
    
    # Validate Table
    send_validated_cmd("CFE_TBL", "CFE_TBL_VALIDATE with ACTIVETBLFLAG 0, TABLENAME #{table_name}")

    # Activate Table
    send_validated_cmd("CFE_TBL", "CFE_TBL_ACTIVATE with TABLENAME #{table_name}")
  end

  # This function starts a file downlink transfer on satelite and
  # validate it using CF and TO HK tlm packets
  def downlinkTransfer(sourceFileName, destFileName, preserve:0, classe:2, channel:0, priority:0, peerID:0.21, custom_wait:nil, check:true)

    download_link = defined?(DOWNLOAD_LINK) ? DOWNLOAD_LINK : 10
    custom_wait ||= defined?(DEFAULT_TIMEOUT) ? DEFAULT_TIMEOUT : 10

    # Initialize counters
    counter = get_tlm_cnt("CF", "CF_HK_PACKET")
    filesSent = tlm("CF CF_HK_PACKET ENG_TOTALFILESSENT")

    # Ask for a file
    cmd("CF CF_PLAYBACK_FILE_CC with   CLASS #{classe},
                      CHANNEL #{channel},
                      PRIORITY #{priority},
                      PRESERVE #{preserve},
                      PEERID \"#{peerID}\",
                      SRCFILENAME \"#{sourceFileName}\",
                      DSTFILENAME \"#{destFileName}\""
    )

    # Wait for successful file transaction
    wait_check_expression("get_tlm_cnt('CF', 'CF_HK_PACKET') > #{counter} and tlm('CF CF_HK_PACKET ENG_TOTALFILESSENT') > #{filesSent}", custom_wait)

    # Verify if file is desired to be here or not
    check_expression("#{File.exist?(destFileName)} == #{check}")
  end

  # This functions handles uplink transfer via CFDP Engine
  # CF HK Packet must be enabled for this to work (relies on OBDH)
  def uplinkTransfer(sourceFileName, destFileName, classe:2, custom_wait:nil, shouldSuccess:true)

    # Those default values may change, but they should be defined in vars
    # Only change if necessary
    default_dest_id = 24
    default_upload_link = 10
    default_ground_uplink_directory = "C:/uplinks/"

    destID = defined?(SAT_ID) ? SAT_ID : default_dest_id
    uplink_link = defined?(UPLOAD_LINK) ? UPLOAD_LINK : default_upload_link
    custom_wait ||= calculateWaitTime(File.size(sourceFileName), uplink_link) + (defined?(DEFAULT_TIMEOUT) ? DEFAULT_TIMEOUT : default_upload_link)

    # Move sourceFileName to uplink directory before uploading.
    uplink_directory = defined?(GROUND_UPLINK_DIRECTORY) ? GROUND_UPLINK_DIRECTORY : default_ground_uplink_directory
    newFileName = uplink_directory + File.basename(sourceFileName)
    FileUtils.cp(sourceFileName, newFileName)

    # Initialize counters
    counter = get_tlm_cnt("CF", "CF_HK_PACKET")
    filesReceived = tlm("CF CF_HK_PACKET APP_TOTALSUCCESSTRANS")
    totalFailedTrans = tlm("CF CF_HK_PACKET APP_TOTALFAILEDTRANS")

    # Send file
    cmd("CFDP SEND_FILE with 
      CLASS #{classe},
      DEST_ID '#{destID}',
      SRCFILENAME '#{newFileName}',
      DSTFILENAME '#{destFileName}'
    ")

    # Wait for successful file transaction
    wait_check_expression("get_tlm_cnt('CF', 'CF_HK_PACKET') > #{counter}", custom_wait)
    wait_check_expression("tlm('CF CF_HK_PACKET APP_TOTALSUCCESSTRANS') > #{filesReceived}", custom_wait) if shouldSuccess
    wait_check_expression("tlm('CF CF_HK_PACKET APP_TOTALFAILEDTRANS') > #{totalFailedTrans}", custom_wait) unless shouldSuccess
  end

  def read_table_item(bin_table_path, def_table_path, bin_table_name, def_table_name, table_name, item_name)  

    begin

      tmc = Cosmos::TableManagerCore.new
    rescue

      require 'cosmos/tools/table_manager/table_manager_core'
      tmc = Cosmos::TableManagerCore.new
    end

    tmc.file_open(File.join(bin_table_path, bin_table_name),
                  File.join(def_table_path, def_table_name))
    
    item_content = tmc.config.tables[table_name].read(item_name)
    
    return item_content
  end
end