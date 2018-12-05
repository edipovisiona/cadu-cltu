require 'cosmos/interfaces/protocols/protocol'
require 'cop1_hkpacket'
require 'cadu/cadu'

module Cosmos
  # Protocol which permanently overrides an item value such that reading the
  # item returns the overriden value. Methods are prefixed with underscores
  # so the API can include the original name which calls out to these
  # methods. Clearing the override requires calling normalize_tlm.
  class CaduProtocol < Protocol

    attr_reader :lastReceivedFrame
    @@maxFrameNumber = 255

    # @param allow_empty_data [true/false] Whether STOP should be returned on empty data
    def initialize(allow_empty_data = false)

      super(allow_empty_data)

      # main data buffer
      @dataBuffer = Array.new

      # error control variables
      @endLeftOver = Hash.new
      @lastReceivedFrame = Hash.new
    end

    # Must be called within receival of any caduFrames on interface
    def updateCounter(vcid, currentFrameNumber)

      if @lastReceivedFrame[vcid].nil?

        Cosmos::Logger.info "Cosmos has probably been shutdown. Initiating caduReader's frame counter on VCID #{vcid}."
        @lastReceivedFrame[vcid] = currentFrameNumber
      else

        Cosmos::Logger.warn "VCID: #{vcid}. Expecting frame ##{nextFrame(@lastReceivedFrame[vcid])}. Received frame ##{currentFrameNumber}" if nextFrame(@lastReceivedFrame[vcid]) != currentFrameNumber
        @lastReceivedFrame[vcid] = currentFrameNumber
      end
    end

    def nextFrame(currentFrame)

      return currentFrame == @@maxFrameNumber ? 0 : currentFrame+1
    end

    def splitFrame?(frame)

      # must return empty array if not
      returnArray = Array.new

      if !frame.startLeftOvers.nil? && !@endLeftOver[frame.VCID].nil?

          begin
            returnArray << TMSourcePacket.new(@endLeftOver[frame.VCID] + frame.startLeftOvers)
          rescue Exception => err
            Cosmos::Logger.warn "Unable to mount packet on vcid #{frame.VCID} due to #{err}"
          end
          @endLeftOver.delete(frame.VCID)
      end

      @endLeftOver[frame.VCID] = frame.endLeftOvers unless frame.endLeftOvers.nil?

      return returnArray
    end

    def insertIntoBuffer(array)

      return if array.nil?
      @dataBuffer += array
    end

    def popFromBuffer

      packet = @dataBuffer.shift
      return packet.nil? ? packet : packet.packetData.pack('c*')
    end


    def read_data(data)

      if data.nil? || data.empty?

        packet = popFromBuffer
        return packet.nil? ? :STOP : packet
      end

      # Try to create a cadu frame or verify if tlm from other things.
      begin

        frame = CADUFrame.new(data.bytes)
        COP1_HKPacket.instance.handleCADUReport(frame.TMTFrame.frameTrailer)
        updateCounter(frame.VCID, frame.frameNumber)

        unless frame.isIdleFrame?

          arrayFrames = frame.getFramesArray
          insertIntoBuffer(splitFrame?(frame)+arrayFrames)
        end
      rescue Utils_visiona::BadLengthError

        # not meant for this protocol
        return data
      rescue Exception => err

        # Failed to create CADU Frame.
        Logger.info "[CADU Protocol] Failed to create frame due to #{err}"
        return data
      end

      # Check if something was created
      return popFromBuffer
    end
  end
end
