class TMTransferFrame

	attr_reader :frameHeader
	attr_reader :startLeftOvers
	attr_reader :endLeftOvers
	attr_reader :dataFieldArray
	attr_reader :frameTrailer
	@@exactlyLength = 1000 # TMTransferFrame should have 1000 bytes exactly
	@@frameHandlerFile = "handlers/framehandler" # This is the file that will handle splitted frames

	def initialize(content)

		# content should have 1000 bytes now (passed verification of CADU Frame)
		# so we can try to verify it's header and trailer

		raise ArgumentError, "Content is nill in TMTransferFrame" if content.nil?
		Utils_visiona.verifyLength("diff", content.length, @@exactlyLength)

		# start TMTHeader with first 6 bytes and TMTFrameTrailer with last 4 bytes
		@frameHeader = TMFrameHeader.new(content[0..5])
		@frameTrailer = TMFrameTrailer.new(content[(content.length-4)..(content.length-1)])

		# frameDataField must have 990 bytes. (removed 6 from frame header, and last 4 for frame trailer)
		frameDataField = content[6..content.length-5]
		@dataFieldArray = Array.new
		return if @frameHeader.isIdleFrame

		# verify FHP and set startLeftOvers if necessary
		@startLeftOvers = frameDataField[0..@frameHeader.firstHeaderPointer-1] unless @frameHeader.firstHeaderPointer == 0

		# now update packets into array
		start = @frameHeader.firstHeaderPointer

		while (start < frameDataField.length)

			begin

				# Try to make packet header
				auxHeader = TMPacketHeader.new(frameDataField[start..(start+5)])

				# Get packet data field length and try to make full packet + 6 bytes for header
				packetDataFieldLength = auxHeader.packetDataFieldLength
				auxPacket = TMSourcePacket.new(frameDataField[start..(start+auxHeader.packetDataFieldLength+6)], header:auxHeader)
				dataFieldArray << auxPacket
				start += auxHeader.packetDataFieldLength+7

			# in case of a verify error, raise an exception and break (probably something went wrong)
			rescue IdlePacket; break
			rescue Utils_visiona::VerifyError
				Utils_visiona.OS_print(1, "VID: #{frameHeader.virtualChannelID}. Could not verify packet #{frameDataField[start..(start+auxHeader.packetDataFieldLength+6)].to_s}")
				raise Utils_visiona::VerifyError
			rescue Utils_visiona::BadLengthError
				# Bad Length Error means i don't have full packet in this telemetry, so i'll start a file and try to complete it in the next telemetry
				# I'm not expecting wrong data field size. If so, total telemetry will be ignored or unexpected behavior will be performed
				Utils_visiona.OS_print(1, "VID: #{frameHeader.virtualChannelID}. I have this data left from frame: #{frameDataField[start..(start+auxHeader.packetDataFieldLength+6)].to_s}")
				@endLeftOvers = frameDataField[start..(start+auxHeader.packetDataFieldLength+6)]
				break
			end
		end
	end

	def getValidPackets
		@dataFieldArray.length
	end

	def valid?
		@frameHeader.valid?
	end

	def to_s

		output = ""
		output << @frameHeader.to_s
		output << "\n"
		#print all telemetryData
		@dataFieldArray.each do |data|
			output << "this is starting packet\n"
			output << data.to_s << "\n"
			output << "this is ending packet\n\n"
		end
		output << @frameTrailer.to_s
		return output
	end
end