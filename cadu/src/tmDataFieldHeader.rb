class TMDataFieldHeader

	#dunno if seconds and milliseconds or days and milliseconds
	attr_accessor :time1
	attr_accessor :time2
	@@exactlyLength = 6

	def initialize(content)

		# verify exactly length for header
		raise ArgumentError, "Content is nill in TMDataFieldHeader" if content.nil?
		Utils_visiona.verifyLength("diff", content.length, @@exactlyLength)

		@time1 = (content[0]<<24) + (content[1]<<16) + (content[2]<<8) + content[3]
		@time2 = (content[4]<<8) + content[5]
	end

	def to_s

		output = ""
		output << "This is starting TMDataFieldHeader" << "\n"
		output << "Time1 = #{@time1}" << "\n"
		output << "Time2 = #{@time2}" << "\n"
		output << "This is ending of TMDataFieldHeader" << "\n"
		return output
	end
end