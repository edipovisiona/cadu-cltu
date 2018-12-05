module Utils_visiona

  # This function is used to get a large number from a byte array
  # For e.g. [1, 1, 2] will return 1<<16 + 1<<8 + 2.
  # big_endian = false will make function consider LITTLE_ENDIAN notation
  # For e.g. [1, 1, 2] will return 1 + 1<<8 + 2<<16
  def getDecimalFromByteArray(content, big_endian = true)

    sum = 0; i = big_endian ? (content.length-1) : 0
    content.each {|x| sum += x<<8*i; i +=1*(big_endian ? -1 : 1)}

    return sum
  end

  def strToDecArray(string)

    arr = Array.new
    string.each_char do |c|
      arr << c.ord
    end
    return arr
  end

  def getDecValueFromHexa(str)

    hexaDict = {"A"=>10, "B"=>11, "C"=>12, "D"=>13, "E"=>14, "F"=>15}
    return hexaDict[str].nil? ? str.to_i : hexaDict[str]
  end

  # This functions return 2 hexas for each byte in array; e.g. [12, 1] = 0C01
  def decArrayToHexaStr(array)

    str = ""
    array.each do |dec|
      aux = dec.to_s(16)
      if aux.length != 2
        aux = "0#{aux}"
      else end
      str << aux
    end
    return str.delete('" [],').upcase
  end

  def hexaStrToDecArray(hexaString)

    packet = Array.new
    for i in (0..hexaString.length-2).step(2)
      aux1 = getDecValueFromHexa(hexaString[i])
      aux2 = getDecValueFromHexa(hexaString[i+1])
      packet << ((aux1 << 4) + aux2)
    end
    return packet
  end

  # this function performs operation to transform id X to 0.x str binary array (eg 21 to "0.21 = [48, 46, 50, 49]"")
  def IDtoStrArray(id)

    strArray = Array.new
    strArray << 48
    strArray << 46

    id.to_s.each_char do |c|
      strArray << c.ord
    end
    return strArray
  end
end