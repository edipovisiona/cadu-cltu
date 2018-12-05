module Utils_visiona

  def getBits (binSequence, bitStart, bitEnd)

    return false if bitStart > bitEnd

    if bitStart==bitEnd
      return 1 if (binSequence & (1 << bitStart-1) != 0)
      return 0
    end

    soma = 0
    for i in 0..(bitEnd-bitStart)
      soma+=2**i if (binSequence & (1 << (bitStart+i)-1) != 0)
    end

    return soma
  end

  def completeBytes(array, expectedSize, type)

    raise "Array is bigger than expected." if array.length > expectedSize

    # I will complete bytes to the left here
    if type.upcase.eql?("LITTLE_ENDIAN")

      while (array.length < expectedSize)
        array.unshift(0)
      end
    # I will complete bytes to the right here
    elsif type.upcase.eql?("BIG_ENDIAN")

      while (array.length < expectedSize)
        array << 0
      end
    end

    return array
  end
end