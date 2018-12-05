class TMSourcePacket

	attr_accessor :packetHeader
	attr_accessor :dataFieldHeader
	attr_accessor :sourceTelemetryDataLength
	attr_accessor :sourceTelemetryData
	attr_accessor :packetErrorControl
	attr_accessor :packetData
	@@minLength = 6 # 6 bytes primary header + 2 bytes crc

	def initialize(content, *args)

		# verify min length
		raise ArgumentError, "Content is nill in TMSourcePacket" if content.nil?
		Utils_visiona.verifyLength("less", content.length, @@minLength)

		# Verify if we receive a header, if not, try to make a packet from first 6 bytes
		@packetHeader = args.empty? ? TMPacketHeader.new(content[0..5]) : args[0][:header]

		# Ready to set telemetry data length
		@sourceTelemetryDataLength = (@packetHeader.packetDataFieldLength)+1

		# verify total packet length
		Utils_visiona.verifyLength("diff", content.length, @sourceTelemetryDataLength+6)

		# packet is ok, set data
		@packetData = content[0..@sourceTelemetryDataLength+6-1]

		# if DFHFlag is 0, means it has no secondary header
		# 6 bytes for secondary header (varies on time format used (can be 48bits or 64bits))
		if (@packetHeader.DFHFlag == 1)

			@dataFieldHeader = TMDataFieldHeader.new(content[6..11])
			# packet data field is size of @sourceTelemetryDataLength, 6 bytes for secondary header, 2 bytes for CRC and others are data
			# start at byte 12 because 6 first bytes are for primary header and bytes 6..11 are for secondary header
			@sourceTelemetryData = content[12..(@sourceTelemetryDataLength+6-3)]
		else

			@dataFieldHeader = nil
			@sourceTelemetryData = content[6..(@sourceTelemetryDataLength+6-3)]
		end

		@packetErrorControl = (content[(@sourceTelemetryDataLength+6-2)]<<8) + content[(@sourceTelemetryDataLength+6-1)]
	end

	def valid?
		@packetHeader.valid?
	end

	def to_s

		output = ""
		output << "This is TMSourcePacket\n"
		output << "#{@packetHeader.to_s}\n #{@dataFieldHeader.to_s}\n"
		output << "Error Control of this packet is #{@packetErrorControl}\n"
		output << "TelemetryData is #{@sourceTelemetryData.to_s}\n"
		output << "TelemetryDataLength is #{@sourceTelemetryData.length}\n"
		output << "This is ending of TMSourcePacket\n"
		return output
	end
end