module CLTU

	class CLTUPacket

		attr_accessor :tcFrame
		@@startSequence = [235, 144]
		@@endSequence = [197, 197, 197, 197, 197, 197, 197, 121]
		@@minLength = 18

		def initialize (*content)

			if (content[0].is_a?(Array))

				content = content[0]

				Utils_visiona.verifyLength("less", content.length, @@minLength)
				valid?(content)
				#p CLTU.removeFillerBit(content[2..(content.length-9)])

				@tcFrame = CLTU::TCTransferFrame.new(content[2..(content.length-9)])
			elsif (content[0].is_a?(Hash))

				content = content[0]
				@tcFrame = content[:tcFrame] unless content[:tcFrame].nil?
			end
		end

		def valid? (*content)

			if (content[0].is_a?(Array))
				content = content[0]
				# verify startSquence
				return true if (content[0..1] == @@startSequence) && (content[(content.length-8)..(content.length-1)] == @@endSequence)
				raise VerifyError, "Error validating CLTU Frame"
			end
		end

		def pack

			valid?
			binArray = Array.new
			binArray << @@startSequence
			binArray << CLTU.insertFillerBit(@tcFrame.pack)
			binArray << @@endSequence

			return binArray.flatten
		end
	end # end class CLTU
end # end module CLTU