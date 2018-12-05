require "utils_visiona/utils"
require_relative "src/tcFrameDataUnit"
require_relative "src/tcFrameHeader"
require_relative "src/tcTransferFrame"
require_relative "src/cltuPacket"

module CLTU

	# this function shall be used to calculate the crc filler bit to insert into cltu
	def calculateFillerBit(array)

		# i'm expecting a 7 bytes array
		Utils_visiona.verifyInput(Array, array.class)
		Utils_visiona.verifyLength("diff", array.length, 7)
		return 0
	end

	# this function inserts a filler bit into content and also complete it's length to % 8
	def insertFillerBit(content)

		# content should have min size of 7
		Utils_visiona.verifyInput(Array, content.class)
		return content if content.length < 7

		# first insert filler bit using filler bit function
		i = 7
		while (i < content.length) do
			content.insert(i, *[calculateFillerBit(content[i-7..i-1])])
			i+=8
		end

		# now must complete to 8bytes packet
		if (content.length % 8) != 0
			for i in 1..(8-(content.length%8))
				content << 0
			end
		end
		return content
	end

	def calculateChecksum(packet)

		Utils_visiona.verifyInput(Array, packet.class)
		checksum = 0xFF
		for i in 0..(packet.length-1); checksum ^= packet[i]; end
		return Utils_visiona.getBits(checksum, 1, 8)
	end

	def removeFillerBit(packet)

		Utils_visiona.verifyInput(Array, packet.class)
		for i in (7..packet.length).step(8)
			packet.delete_at(i)
		end
		return packet
	end

	module_function :calculateFillerBit
	module_function :insertFillerBit
	module_function :calculateChecksum
	module_function :removeFillerBit
end