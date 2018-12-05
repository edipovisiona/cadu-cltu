module CLTU

	class TCTransferFrame

		attr_accessor :frameHeader
		attr_accessor :frameDataUnit
		@@minLength = 8

		def initialize(*content)

			if (content[0].is_a?(Array))

				content = content[0]
				Utils_visiona.verifyLength("less", content.length, @@minLength)
				@frameHeader = CLTU::TCFrameHeader.new(content[0..4])
				length = @frameHeader.frameLength
				Utils_visiona.verifyLength("diff", content.length, length+1)
				@frameDataUnit = CLTU::TCFrameDataUnit.new(content[5..content.length])
			elsif (content[0].is_a?(Hash))

				content = content[0]
				@frameHeader = content[:frameHeader] unless content[:frameHeader].nil?
				@frameDataUnit = content[:frameDataUnit] unless content[:frameDataUnit].nil?
			end
		end

		def pack

			return @frameHeader.pack + (@frameDataUnit.nil? ? [] : @frameDataUnit.pack)
		end
	end # end class TCTransferFrame
end