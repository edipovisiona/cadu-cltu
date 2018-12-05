require 'utils_visiona/utils'
require_relative 'src/tmTransferFrame'
require_relative 'src/tmFrameTrailer'
require_relative 'src/tmFrameHeader'
require_relative 'src/tmSourcePacket'
require_relative 'src/tmPacketHeader'
require_relative 'src/tmDataFieldHeader'

class IdleFrame < StandardError; end
class IdlePacket < StandardError; end

class CADUFrame

	attr_accessor :TMTFrame
	FRAME_LENGTH = 1004 # CADU frame should have 1004 bytes (defined by obdh team)
	@@marker = [0x1A, 0xCF, 0xFC, 0x1D] # first 4 bytes marker

	def initialize(content)

		# Verify content length
		raise ArgumentError, "Content is nill in TMTFrame" if content.nil?
		Utils_visiona.verifyLength("diff", content.length, FRAME_LENGTH)
		Utils_visiona.verifyInput(Array, content.class)

		# Verify marker for CADU Frame
		# It can raise a IdleFrame exception which should be treated outside
		@TMTFrame = TMTransferFrame.new(content[4..(content.length-1)]) if valid?(content[0..3])
	end

	def getFramesArray
		@TMTFrame.dataFieldArray unless @TMTFrame.nil?
	end

	# Check for CADU Frame marker
	def valid?(content)

		# Verify if first 4 bytes are 1ACFFC1D
		unless ((@@marker[0] == content[0]) && (@@marker[1] == content[1]) && (@@marker[2] == content[2]) && (@@marker[3] == content[3]))
			Utils_visiona.OS_print(0, "Verification marker is #{Utils_visiona.decArrayToHexaStr(content[0..3])}; should be 1ACFFC1D. Not a CADU frame")
			raise Utils_visiona::VerifyError, "Verification marker is #{Utils_visiona.decArrayToHexaStr(content[0..3])}; should be 1ACFFC1D. Not a CADU frame"
		end
		return true
	end

	def VCID
		@TMTFrame.frameHeader.virtualChannelID
	end

	def startLeftOvers
		@TMTFrame.startLeftOvers
	end

	def endLeftOvers
		@TMTFrame.endLeftOvers
	end

	def frameNumber
		@TMTFrame.frameHeader.virtualChannelFrameCount
	end

	def isIdleFrame?
		@TMTFrame.frameHeader.isIdleFrame
	end

	def to_s
		@TMTFrame.to_s
	end
end