# This function relies on TO_HK_PACKET (It must be enabled).
# Use this function to fix CI communication.
def fixCISequence(channel)

  default_timeout = 5

  target_name = "COP1_TRAILER_VC_#{channel}"
  # Must verify if we have telemetry first
  counter = get_tlm_cnt("TO", "TO_HK_PACKET")

  begin

    wait_check_expression("get_tlm_cnt('TO', 'TO_HK_PACKET') > #{counter}", default_timeout)
  rescue

    puts "Error. CmdTlmSrvr is not receiving TO_HK_PACKETs."
    raise
  end

  # Verify if we have CLCW comming from desired channel
  counter = get_tlm_cnt("COP1", "#{target_name}")

  begin

    wait_check_expression("get_tlm_cnt('COP1', '#{target_name}') > #{counter}", default_timeout)
  rescue

    puts "Error. Not receiving CLCW tlms for #{target_name}."
    raise
  end

  # Verify if CLCW is in lockout
  if tlm("COP1 #{target_name} LOCKOUT").to_i == 1

    begin

      counter = tlm("COP1 #{target_name} FARM_B_COUNT").to_i
      expected = counter==3 ? 0 : counter+1
      cmd("COP1 UNLOCK with VCID #{channel}, SPARE 0").to_i
      wait_check_expression("tlm('COP1 #{target_name} FARM_B_COUNT').to_i == #{expected}", default_timeout)
      wait_check_expression("tlm('COP1 #{target_name} LOCKOUT').to_i == 0", default_timeout)
    rescue

      puts "Error. Bypass command didn't work."
      raise
    end
  end

  # Set CLTU Sequence Number to report value
  expectedValue = tlm("COP1 #{target_name} REPORT_VALUE").to_i
  cmd("COP1 SET_CLTU_SQNC_NUMBER with VCID #{channel}, SQNC_NUMBER #{expectedValue}")
end