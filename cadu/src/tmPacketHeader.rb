class TMPacketHeader

	attr_accessor :version
	attr_accessor :type
	attr_accessor :DFHFlag
	attr_accessor :PID
	attr_accessor :pktCat
	attr_accessor :sequenceFlag
	attr_accessor :sequenceCount
	attr_accessor :packetDataFieldLength
	attr_accessor :marker
	@@minLength = 6

	def initialize(content)

		# verify exactly length for header
		raise ArgumentError, "Content is nill in TMTransferFrame" if content.nil?
		Utils_visiona.verifyLength("less", content.length, @@minLength)

		@marker = content[0..1]
		@version = Utils_visiona.getBits(content[0], 6, 8)
		@type = Utils_visiona.getBits(content[0], 5, 5)
		@DFHFlag = Utils_visiona.getBits(content[0], 4, 4)
		@PID = (Utils_visiona.getBits(content[0], 1, 3) << 4) + (Utils_visiona.getBits(content[1], 5, 8))
		@pktCat = Utils_visiona.getBits(content[1], 1, 4)
		@sequenceFlag = Utils_visiona.getBits(content[2], 7, 8)
		@sequenceCount = (Utils_visiona.getBits(content[2], 1, 6) << 14) + content[3]
		@packetDataFieldLength = (content[4] << 8) + content[5]
		valid?
	end

	def valid?

		Utils_visiona.compareValues(@version, 0, "should be 0; not #{@version}")
		Utils_visiona.compareValues(@type, 0, "should be 0; not #{@type}")
		Utils_visiona.compareValues(@sequenceFlag, 3, "should be 3; not #{@sequenceFlag}")

		if ((@marker[0] == 0x03) & (@marker[1] == 0xFF))
			Utils_visiona.OS_print(1, "I have one idle packet starting with 0x03FF. It's been ignored.")
			raise IdlePacket, "I have one idle packet starting with 0x03FF. It's been ignored."
		end
	end

	def to_s

		output = ""
		output << "This is starting of TMPacket Header" << "\n"
		output << "Version = #{@version}" << "\n"
		output << "Type = #{@type}" << "\n"
		output << "DFHFlag = #{@DFHFlag}" << "\n"
		output << "PID = #{@PID}" << "\n"
		output << "PktCAT = #{@pktCat}" << "\n"
		output << "SequenceFlag = #{@sequenceFlag}" << "\n"
		output << "SequenceCount = #{@sequenceCount}" << "\n"
		output << "PacketDataFieldLength = #{@packetDataFieldLength}" << "\n"
		output << "This is ending of TMPacket Header" << "\n"
		return output
	end
end