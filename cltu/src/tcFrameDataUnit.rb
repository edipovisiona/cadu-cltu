module CLTU

	class TCFrameDataUnit

		attr_accessor :dataArray
		@@minLength = 8

		def initialize(*content)

			if (content[0].is_a?(Array))

				content = content[0]
				Utils_visiona.verifyLength("less", content.length, @@minLength)
				@dataArray = Array.new
				i = 0
				while (i < (content.length-1)) do
					headerLength = ((content[i+4])<<8) + content[i+5]
					@dataArray << content[i..(i+headerLength+6)] unless content[i..(i+headerLength+6)].empty?
					i += headerLength+7
				end
			elsif (content[0].is_a?(Hash))

				content = content[0]
				@dataArray = content[:dataArray] unless content[:dataArray].nil?
			end
		end

		def valid?

			raise StandardError if @dataArray.nil?
		end

		def pack

			valid?
			binArray = Array.new
			binArray << @dataArray
			return binArray.flatten
		end

		def to_s

			@dataArray.each do |a|
				p a
			end
		end
	end
end