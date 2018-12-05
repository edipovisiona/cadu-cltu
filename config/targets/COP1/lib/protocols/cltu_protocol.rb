require 'cosmos/interfaces/protocols/protocol'
require 'cltu/cltu'

module Cosmos

  # Protocol which permanently overrides an item value such that reading the
  # item returns the overriden value. Methods are prefixed with underscores
  # so the API can include the original name which calls out to these
  # methods. Clearing the override requires calling normalize_tlm.
  class CltuProtocol < Protocol

    attr_reader :sequenceNumber
    attr_reader :sequenceCounter
    attr_reader :cmdSequence
    MAX_BYTES = 500
    SPACECRAFT_ID = 66

    # @param allow_empty_data [true/false] Whether STOP should be returned on empty data
    def initialize(allow_empty_data = false)

      super(allow_empty_data)
      @sequenceCounter = Hash.new
      @sequenceNumber = Hash.new
      @cmdSequence = Hash.new{|hsh,key| hsh[key] = []}
    end

    def insertCmd(command, virtualChannelID)

      command = command.dup
      # timeout should be handle outside of this function, by calling returnCLTU function
      # handle size verification here.
      if command.length > MAX_BYTES
        raise StandardError, "Command exceeds max length of #{MAX_BYTES}"
      end

      #calculate command checksum. always is @ pos 6
      command[6] = CLTU.calculateChecksum(command)

      if (@cmdSequence[virtualChannelID].flatten.length + command.length) > MAX_BYTES
        # i've reached max and can't add this command. I will return a CLTU and put this command as new
        aux = returnCLTU(virtualChannelID)
        @cmdSequence[virtualChannelID] << command
        return aux
      else
        # ok to add command
        @cmdSequence[virtualChannelID] << command
        return nil
      end
    end

    def returnCLTU(virtualChannelID)

      # verify if there is something to return
      return nil if @cmdSequence[virtualChannelID].empty?

      aux = @cmdSequence[virtualChannelID].dup
      @cmdSequence.delete(virtualChannelID)
      return generateSingleCLTU(aux, virtualChannelID)
    end

    def generateSetVrFrame(virtualChannelID, vr)

      Utils_visiona.verifyInput(Integer, virtualChannelID.class)
      Utils_visiona.verifyInput(Integer, vr.class)

      command = [0x82, 0x00, vr]

      data = CLTU::TCFrameDataUnit.new(dataArray:command)

      # header length will be calculate upon .pack call
      header = CLTU::TCFrameHeader.new(version:0, bypassFlag:1, controlCmdFlag:1, spacecraftID:SPACECRAFT_ID,
      virtualChannelID:virtualChannelID, frameLength:command.flatten.length+4, frameSequenceNumber:0)
      packet = CLTU::CLTUPacket.new(tcFrame:CLTU::TCTransferFrame.new(frameHeader:header, frameDataUnit:data))

      return packet.pack
    end

    def generateUnlockFrame(virtualChannelID)

      Utils_visiona.verifyInput(Integer, virtualChannelID.class)

      command = [0x00]

      data = CLTU::TCFrameDataUnit.new(dataArray:command)

      # header length will be calculate upon .pack call
      header = CLTU::TCFrameHeader.new(version:0, bypassFlag:1, controlCmdFlag:1, spacecraftID:SPACECRAFT_ID,
      virtualChannelID:virtualChannelID, frameLength:command.flatten.length+4, frameSequenceNumber:0)
      packet = CLTU::CLTUPacket.new(tcFrame:CLTU::TCTransferFrame.new(frameHeader:header, frameDataUnit:data))

      return packet.pack
    end

    def generateSingleCLTU(command, virtualChannelID, bypass = false, controlCmdFlag = false)

      Utils_visiona.verifyInput(Array, command.class)
      Utils_visiona.verifyInput(Integer, virtualChannelID.class)

      command = command.dup

      @sequenceCounter[virtualChannelID] = 0 if @sequenceCounter[virtualChannelID].nil?

      command[2] = Utils_visiona.getBits(@sequenceCounter[virtualChannelID], 9, 14)
      command[3] = Utils_visiona.getBits(@sequenceCounter[virtualChannelID], 1, 8)
      @sequenceCounter[virtualChannelID] = Utils_visiona.getBits(@sequenceCounter[virtualChannelID], 1, 14) + 1; # 14 bits

      if command[0].is_a?(Integer)
        command[6] = CLTU.calculateChecksum(command)
      end

      data = CLTU::TCFrameDataUnit.new(dataArray:command)

      # header length will be calculate upon .pack call
      header = CLTU::TCFrameHeader.new(version:0, bypassFlag:(bypass==false ? 0 : 1), controlCmdFlag:(controlCmdFlag==false ? 0 : 1), spacecraftID:SPACECRAFT_ID,
      virtualChannelID:virtualChannelID, frameLength:command.flatten.length+4, frameSequenceNumber:(bypass==false ? generateSequenceNumber(virtualChannelID) : 0))
      packet = CLTU::CLTUPacket.new(tcFrame:CLTU::TCTransferFrame.new(frameHeader:header, frameDataUnit:data))

      return packet.pack
    end

    def generateSequenceNumber(virtualChannel)

      @sequenceNumber[virtualChannel] = (@sequenceNumber[virtualChannel].nil? ? 0 : @sequenceNumber[virtualChannel]+1) % (2**8)
      return @sequenceNumber[virtualChannel]
    end

    # This function is executed before writing data
    def write_packet(packet)

      @packet_name = packet.target_name.upcase
      if @packet_name.eql?(COP1_TARGET_NAME)

        case packet.packet_name
        when "SET_CLTU_PACKET_SQNC_COUNTER"

          @sequenceCounter[packet.read('VCID', :FORMATTED).to_i] = packet.read('SQNC_COUNTER', :FORMATTED).to_i
          Logger.info "VCID ##{packet.read('VCID', :FORMATTED).to_i} counter set to #{packet.read('SQNC_COUNTER', :FORMATTED).to_i}"
          packet = :STOP
        when "SET_CLTU_FRAME_SQNC_NUMBER"

          @sequenceNumber[packet.read('VCID', :FORMATTED).to_i] = ((packet.read('SQNC_NUMBER', :FORMATTED).to_i)-1)
          Logger.info "VCID ##{packet.read('VCID', :FORMATTED).to_i} number set to #{packet.read('SQNC_NUMBER', :FORMATTED).to_i}"
          packet = :STOP
        when "UNLOCK"

          buffer = generateUnlockFrame(packet.read('VCID', :FORMATTED).to_i)
          packet.buffer = buffer.pack('c*')
          @bypass = true
        when "BYPASS_NEXT"

          @bypass_next = true
          packet = :STOP
        when "SETVR"

          buffer = generateSetVrFrame(packet.read('VCID', :FORMATTED).to_i, packet.read('VR', :FORMATTED).to_i)
          packet.buffer = buffer.pack('c*')
          @bypass = true
        end
      end

      return packet
    end

    # Called to perform modifications on a read packet before it is given to the user
    #
    # @param packet [Packet] Original packet
    # @return [Packet] Potentially modified packet
    def write_data(data)

      # this is for unlock frame bypass
      if @bypass

        @bypass = false
        return data
      end

      vcid = 0

      # This tries to get #TARGET_VCID from defines. If not, set to default (0)
      begin; vcid = eval "#{@packet_name}_VCID"; rescue; vcid=0; end

      packet = generateSingleCLTU(data.bytes, vcid, (@bypass_next==true ? true : false)).pack('c*')
      @bypass_next = false if @bypass_next
      return packet
    end
  end
end