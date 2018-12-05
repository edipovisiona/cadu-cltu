module CLTU

	class TCFrameHeader

		attr_accessor :version
		attr_accessor :bypassFlag
		attr_accessor :controlCmdFlag
		attr_accessor :spacecraftID
		attr_accessor :virtualChannelID
		attr_accessor :frameLength
		attr_accessor :frameSequenceNumber
		@@exactlyLength = 5
		@@totalVariblesInstanceds = 7

		def initialize(*content)

			if (content[0].is_a?(Array))

				content = content[0]

				# Verify Header Length
				Utils_visiona.verifyLength("diff", content.length, @@exactlyLength)
				Utils_visiona.compareValues(Utils_visiona.getBits(content[0], 3, 4), 0, "spare bits")
				# Set up stuff
				@version = Utils_visiona.getBits(content[0], 7, 8)
				@bypassFlag = Utils_visiona.getBits(content[0], 6, 6)
				@controlCmdFlag = Utils_visiona.getBits(content[0], 5, 5)
				@spacecraftID = (Utils_visiona.getBits(content[0], 1, 2) << 8) + content[1]
				@virtualChannelID = Utils_visiona.getBits(content[2], 3, 8)
				@frameLength = (Utils_visiona.getBits(content[2], 1, 2) << 8) + content[3]
				@frameSequenceNumber = content[4]

				# Check if everything is ok
				valid?
			elsif (content[0].is_a?(Hash))

				content = content[0]
				@version = content[:version] unless content[:version].nil?
				@bypassFlag = content[:bypassFlag] unless content[:bypassFlag].nil?
				@controlCmdFlag = content[:controlCmdFlag] unless content[:controlCmdFlag].nil?
				@spacecraftID = content[:spacecraftID] unless content[:spacecraftID].nil?
				@virtualChannelID = content[:virtualChannelID] unless content[:virtualChannelID].nil?
				@frameLength = content[:frameLength] unless content[:frameLength].nil?
				@frameSequenceNumber = content[:frameSequenceNumber] unless content[:frameSequenceNumber].nil?
			end
		end

		def valid?

			Utils_visiona.compareValues(self.instance_variables.length, @@totalVariblesInstanceds, "variables instanceds")
			return true
		end

		def pack

			valid?
			binArray = Array.new
			binArray << ((@version<<6) + (@bypassFlag<<5) + (@controlCmdFlag<<4) + (Utils_visiona.getBits(@spacecraftID, 9, 10)))
			binArray << Utils_visiona.getBits(@spacecraftID, 1, 8)
			binArray << (Utils_visiona.getBits(@virtualChannelID, 1, 6) << 2) + Utils_visiona.getBits(@frameLength, 9, 10)
			binArray << Utils_visiona.getBits(@frameLength, 1, 8)
			binArray << @frameSequenceNumber
			return binArray
		end

		def to_s

			output = ""
			output << "This is starting Frame Header \n"
			output << "Version = #{@version}\n"
			output << "Bypass Flag = #{@bypassFlag}\n"
			output << "Control Cmd Flag = #{@controlCmdFlag}\n"
			output << "SpacecraftID = #{@spacecraftID}\n"
			output << "VirtualChannelID = #{@virtualChannelID}\n"
			output << "Frame Length = #{@frameLength}\n"
			output << "Frame Sequence Number = #{@frameSequenceNumber}\n"
			return output
		end
	end # class TCFrameHeader
end # module CLTU