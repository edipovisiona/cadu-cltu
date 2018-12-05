module Utils_visiona

  CCSDS_HEADER_LENGTH = 8

  def removeCCSDSHeader(pdu)

    return pdu[CCSDS_HEADER_LENGTH..(pdu.length-1)]
  end
end