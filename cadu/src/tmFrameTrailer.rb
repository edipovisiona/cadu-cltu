class TMFrameTrailer

	attr_reader :statusFields
	attr_reader :virtualChannelID
	attr_reader :noRFAvail
	attr_reader :noBitLock
	attr_reader :lockOut
	attr_reader :wait
	attr_reader :retransmit
	attr_reader :farmBCount
	attr_reader :reportValue
	@@exactlyLength = 4 # TMFrameTrailer must have 4 bytes

	def initialize(content)

		Utils_visiona.verifyLength("diff", content.length, @@exactlyLength)

		@statusFields = Utils_visiona.getBits(content[0], 3, 5)
		@virtualChannelID = Utils_visiona.getBits(content[1], 3, 8)
		@noRFAvail = Utils_visiona.getBits(content[2], 8, 8)
		@noBitLock = Utils_visiona.getBits(content[2], 7, 7)
		@lockOut = Utils_visiona.getBits(content[2], 6, 6)
		@wait = Utils_visiona.getBits(content[2], 5, 5)
		@retransmit = Utils_visiona.getBits(content[2], 4, 4)
		@farmBCount = Utils_visiona.getBits(content[2], 2, 3)
		@reportValue = content[3]
	end

	def to_s

		output = ""
		output << "This is starting Transfer Frame Trailer" << "\n"
		output << "Status Fields = #{@statusFields}" << "\n"
		output << "Virtual Channel ID = #{@virtualChannelID}" << "\n"
		output << "No RF Avail = #{@noRFAvail}" << "\n"
		output << "No Bit Lock = #{@noBitLock}" << "\n"
		output << "Lockout = #{@lockOut}" << "\n"
		output << "WAIT = #{@wait}" << "\n"
		output << "Retransmit = #{@retransmit}" << "\n"
		output << "Farm B Count = #{@farmBCount}" << "\n"
		output << "Report Value = #{@reportValue}" << "\n"
		output << "This is ending Transfer Frame Trailer" << "\n"
		return output
	end
end