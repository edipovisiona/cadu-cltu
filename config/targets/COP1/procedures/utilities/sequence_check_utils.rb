require 'utils_visiona/utils'

def TO_enable?(ip, destport, routemask, ifiledesc, default_timeout)

	counter = get_tlm_cnt("TO", "TO_HK_PACKET")
	begin
		wait_check_expression("get_tlm_cnt(\"CI\", \"CI_HK_PACKET\") > #{counter}", default_timeout)
	rescue
		cmd("TO TO_ENABLE_OUTPUT with IP \"#{ip}\", DESTPORT #{destport}, ROUTEMASK #{routemask}, IFILEDESC #{ifiledesc}")
		wait_check_expression("get_tlm_cnt(\"TO\", \"TO_HK_PACKET\") > #{counter}", default_timeout)
	end
end

def enableSqncCheck(channel, default_timeout)

	Utils_visiona.verifyInput(Integer, channel.class)
	Utils_visiona.verifyInput(Integer, default_timeout.class)
	raise ArgumentError unless (channel == 0 || channel == 1)

	counter = get_tlm_cnt("CI", "CI_HK_PACKET")

	begin

		wait_check_expression("get_tlm_cnt(\"CI\", \"CI_HK_PACKET\") > #{counter}", default_timeout)

		if channel==0

			return true if (tlm("CI", "CI_HK_PACKET", "CH0SQCCNTFLAG") == 1)

			cmd("CI CI_ENABLE_SQNC_CHECK with VC_ID #{channel}")
			wait_check_expression("tlm(\"CI\", \"CI_HK_PACKET\", \"CH0SQCCNTFLAG\") == 1", default_timeout)
		else

			return true if (tlm("CI", "CI_HK_PACKET", "CH1SQCCNTFLAG") == 1)

			cmd("CI CI_ENABLE_SQNC_CHECK with VC_ID #{channel}")
			wait_check_expression("tlm(\"CI\", \"CI_HK_PACKET\", \"CH0SQCCNTFLAG\") == 1", default_timeout)
		end

		return true
	rescue

		counter2 = get_tlm_cnt("TO", "TO_HK_PACKET")
		wait_check_expression("get_tlm_cnt(\"TO\", \"TO_HK_PACKET\") > #{counter2}", default_timeout)
		puts "Error. CI not sending HK packets"
		return false
	end

	puts "Error. TO not sending HK packets"
	return false
end

def adjustSqncCounter(channel, default_timeout)

	Utils_visiona.verifyInput(Integer, channel.class)
	Utils_visiona.verifyInput(Integer, default_timeout.class)
	raise ArgumentError unless (channel == 0 || channel == 1)

	counter = get_tlm_cnt("CI", "CI_HK_PACKET")

	begin

		wait_check_expression("get_tlm_cnt(\"CI\", \"CI_HK_PACKET\") > #{counter}", default_timeout)

		sqncCount = channel == 0? tlm("CI", "CI_HK_PACKET", "CH0SQCCNT") : tlm("CI", "CI_HK_PACKET", "CH1SQCCNT")
		cmd("SYSTEM CI_SET_SQNC_COUNTER with VCID #{channel}, SQNC_COUNTER #{sqncCount}")
		wait(1)
		return true
	rescue

		counter2 = get_tlm_cnt("TO", "TO_HK_PACKET")
		wait_check_expression("get_tlm_cnt(\"TO\", \"TO_HK_PACKET\") > #{counter2}", default_timeout)
		puts "Error. CI not sending HK packets"
		return false
	end

	puts "Error. TO not sending HK packets"
	return false
end