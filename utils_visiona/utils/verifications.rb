module Utils_visiona

  class BadLengthError < StandardError; end
  class VerifyError < StandardError; end
  class NoTargetError < StandardError; end

  def hasSymbol?(hashe, symbol, data_type, bits)

    return false if hashe[symbol].nil?
    return false unless hashe[symbol].is_a?(data_type)

    if data_type == Integer

      # Check for int (byte) stuff
      return false if hashe[symbol] < 0
      return false if hashe[symbol] >= (2**bits)
    elsif data_type == Array

      # Check for array stuff
      for i in 0..hashe[symbol].length-1 do

        return false if hashe[symbol][i] < 0
        return false if hashe[symbol][i] >= (2**bits)
      end
    end

    return true
  end

  def checkByteArray(array)

    raise VerifyError, "Invalid input #{array.class}" unless array.is_a?(Array)

    array.each do |ele|

      verifyInput(Integer, ele.class)
      raise VerifyError, "Not a byte" unless (ele >= 0 and ele < 256)
    end
  end

  def verifyLength(operation, actual, expected)

    case operation.upcase
    when "LESS"

      if actual < expected
        OS_print(0, "Expected min length \"#{expected}\". Got \"#{actual}\"")
        raise BadLengthError, "Expected min length \"#{expected}\". Got \"#{actual}\""
      end
    when "DIFF"

      if actual != expected
        OS_print(0, "Expected exactly length \"#{expected}\". Got \"#{actual}\"")
        raise BadLengthError, "Expected exactly length \"#{expected}\". Got \"#{actual}\""
      end
    when "BIGGER"

      if actual > expected
        OS_print(0, "Expected max length \"#{expected}\". Got \"#{actual}\"")
        raise BadLengthError, "Expected max length \"#{expected}\". Got \"#{actual}\""
      end
    else
      raise ArgumentError, "Invalid operation for verifyLength function"
    end
  end

  def compareValues(actual, expected, msg)

    unless actual == expected
      OS_print(0, "Should have \"#{expected}\" #{msg}. Got \"#{actual}\"")
      raise VerifyError, "Should have \"#{expected}\" #{msg}. Got \"#{actual}\""
    end
  end

  def verifyInput(expected, actual)

    if expected.is_a?(Array)

      if !expected.include?(actual)

        puts "#{caller}\n. Expected object of classes #{expected.to_s}." + " Received " + (actual.nil? ? "nil" : "#{actual}")
        raise ArgumentError, "#{caller}\n. Expected object of classes #{expected.to_s}. Received " + (actual.nil? ? "nil" : "#{actual}")
      end
    else

      if expected != actual

        puts "#{caller}\n. Expected object of class " + (expected.nil? ? "nil." : "#{expected}.") + " Received " + (actual.nil? ? "nil" : "#{actual}")
        raise ArgumentError, "#{caller}\n. Expected object of class " + (expected.nil? ? "nil." : "#{expected}.") + " Received " + (actual.nil? ? "nil" : "#{actual}")
      end
    end
  end
end