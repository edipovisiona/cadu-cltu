module Utils_visiona

  CFDP_CLASS_HASH = {"CFDP::PDUMetadata"=>0, "CFDP::PDUFileData"=>1, "CFDP::PDUFinished"=>2,
    "CFDP::PDUNAK"=>3, "CFDP::PDUEOF"=>4, "CFDP::PDUACK"=>5}

  # This monkey patch is used to check if a string contains
  # multiples substrings (in any order)
  class String

    def minclude?(arg)

      raise ArgumentError unless arg.is_a?(Array)

      arg.each do |arg1|
        return false unless self.include?(arg1)
      end
      return true
    end
  end

  def skip_test(info)

    raise Cosmos::SkipTestCase, info  
  end

  def print_current_test_info

    status_bar("#{Cosmos::Test.current_test_case}")
    puts "Running #{Cosmos::Test.current_test_suite}: #{Cosmos::Test.current_test}: #{Cosmos::Test.current_test_case}}"
  end

  def miss_pdus(*args)

    miss_sent_hash = args[0][:miss_sent_pdus]
    unless miss_sent_hash.nil?

      miss_sent_hash.each do |key, value|
        cmd("CFDP_TEST MISS_SENT_PACKET with PDU_CLASS #{CFDP_CLASS_HASH[key.to_s]}, PACKET_NUMBER_ARRAY #{value}")
      end
    end

    miss_received_hash = args[0][:miss_received_pdus]
    unless miss_received_hash.nil?

      miss_received_hash.each do |key, value|
        cmd("CFDP_TEST MISS_RECEIVED_PACKET with PDU_CLASS #{CFDP_CLASS_HASH[key.to_s]}, PACKET_NUMBER_ARRAY #{value}")
      end
    end
    wait(1)
  end

  def createMainTestDir(current_test_suite, current_test, current_test_case)

    time = Time.now
    mainTestDir = Cosmos::USERPATH+"/outputs/tests/"

    Dir.mkdir(mainTestDir+current_test_suite.to_s) unless Dir.exist?(mainTestDir+current_test_suite.to_s)
    Dir.mkdir(mainTestDir+"#{current_test_suite}/#{current_test}") unless Dir.exist?(mainTestDir+"#{current_test_suite}/#{current_test}")
    Dir.mkdir(mainTestDir+"#{current_test_suite}/#{current_test}/" + current_test_case.to_s) unless Dir.exist?(mainTestDir+"#{current_test_suite}/#{current_test}/" + current_test_case.to_s)
    finalTestDir = mainTestDir+"#{current_test_suite}/#{current_test}/" + current_test_case.to_s
    finalTestDir += "/" + time.strftime("%Y%m%d_%H%M%S")
    Dir.mkdir(finalTestDir)
    Dir.mkdir(finalTestDir+"/input")
    Dir.mkdir(finalTestDir+"/output")

    return finalTestDir
  end

  def createRandomFile(fileName, size)

    File.open(fileName, 'wb+') do |f|
      size.to_i.times {
        f.write(SecureRandom.random_bytes((1<<10)))
      }
    end
  end

  def printFullHash(hash)

    return "nil" if (hash.nil? || hash.empty?)
    hashoutput = ""
    hash.each { |key, value| hashoutput << "#{key}=>#{value.to_s}, " }
    return "{#{hashoutput.chop!.chop!}}"
  end
end