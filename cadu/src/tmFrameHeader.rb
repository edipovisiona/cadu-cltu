class TMFrameHeader

	attr_reader :version
	attr_reader :spacecraftID
	attr_reader :virtualChannelID
	attr_reader :opCtrlFlag
	attr_reader :masterChannelFrameCount
	attr_reader :virtualChannelFrameCount
	attr_reader :DFHFlag
	attr_reader :syncFlag
	attr_reader :pktOrderFlag
	attr_reader :segmentLengthID
	attr_reader :firstHeaderPointer
	attr_reader :isIdleFrame
	@@exactlyLength = 6 # TMFrame header must have 6 bytes

	def initialize(content)

		raise ArgumentError, "Content is nill in TMFrameHeader" if content.nil?
		Utils_visiona.verifyLength("diff", content.length, @@exactlyLength)

		@version = Utils_visiona.getBits(content[0], 7, 8)
		@spacecraftID = (Utils_visiona.getBits(content[0], 1, 6) << 4) + (Utils_visiona.getBits(content[1], 5, 8))
		@virtualChannelID = Utils_visiona.getBits(content[1], 2, 4)
		@opCtrlFlag = Utils_visiona.getBits(content[1], 1, 1)
		@masterChannelFrameCount = content[2]
		@virtualChannelFrameCount = content[3]
		@DFHFlag = Utils_visiona.getBits(content[4], 8, 8)
		@syncFlag = Utils_visiona.getBits(content[4], 7, 7)
		@pktOrderFlag = Utils_visiona.getBits(content[4], 6, 6)
		@segmentLengthID = Utils_visiona.getBits(content[4], 4, 5)
		@firstHeaderPointer = (Utils_visiona.getBits(content[4], 1, 3) << 8) + content[5]
		valid?
	end

	#this is header verification
	def valid?

		Utils_visiona.compareValues(@version, 0, "should be 0; not #{@version}")
		Utils_visiona.compareValues(@DFHFlag, 0, "should be 0; not #{@DFHFlag}")
		Utils_visiona.compareValues(@syncFlag, 0, "should be 0; not #{@syncFlag}")
		Utils_visiona.compareValues(@pktOrderFlag, 0, "should be 0; not #{@pktOrderFlag}")
		Utils_visiona.compareValues(@segmentLengthID, 3, "should be 3; not #{@segmentLengthID}")
		@isIdleFrame = @firstHeaderPointer == 2046 ? true : false

		return true
	end

	def to_s

		output = ""
		output << "This is starting TMT Frame Header" << "\n"
		output << "Version = #{@version}" << "\n"
		output << "SpacecraftID = #{@spacecraftID}" << "\n"
		output << "VirtualChannelID = #{@virtualChannelID}" << "\n"
		output << "OPCtrlFlag = #{@opCtrlFlag}" << "\n"
		output << "MasterChannelFrameCount = #{@masterChannelFrameCount}" << "\n"
		output << "VirtualChannelFrameCount = #{@virtualChannelFrameCount}" << "\n"
		output << "DFHFlag = #{@DFHFlag}" << "\n"
		output << "SyncFlag = #{@syncFlag}" << "\n"
		output << "PKTOrderFlag = #{@pktOrderFlag}" << "\n"
		output << "SegmentLengthID = #{@segmentLengthID}" << "\n"
		output << "FirstHeaderPointer = #{@firstHeaderPointer}" << "\n"
		output << "This is ending TMT Frame Header" << "\n"
		return output
	end
end