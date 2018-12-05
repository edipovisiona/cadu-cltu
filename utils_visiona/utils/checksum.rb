module Utils_visiona

  def calculateFileChecksum(fileName)

    begin

      sum = 0
      File.open(fileName, 'rb') do |file|

        until file.eof?

            buffer = file.read(4)

        (sum += buffer.unpack('L>')[0]; next) if buffer.length == 4
        for i in 0..(buffer.length-1); sum += (buffer[i].ord<<(8*(4-i-1))); end
        end
      end
      return Utils_visiona.getBits(sum, 1, 32)
    rescue Exception => err

      puts "Error is" + err
    end
  end
end