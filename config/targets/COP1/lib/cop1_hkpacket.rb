require "utils_visiona/utils"
require 'singleton'
require 'cadu/cadu'
require 'thread'

class COP1_HKPacket

  include Singleton

  attr_reader :hkPacketBuffer
  attr_reader :vcid_hk_timer
  attr_reader :vcid_hk_flags

  def initialize

    @hkPacketBuffer = Array.new
    @mutex = Mutex.new
    @vcid_hk_timer = Hash.new
    @vcid_hk_flags = Hash.new
  end

  def pack

    @mutex.synchronize {
      return @hkPacketBuffer.shift
    }
  end

  def insert_into_buffer(packet)

    @mutex.synchronize {
      @hkPacketBuffer << packet
    }
  end

  def getFlags(trailer)

    return (Utils_visiona.getBits(trailer.statusFields, 1, 3) << 7) +
    (Utils_visiona.getBits(trailer.noRFAvail, 1, 1) << 6) +
    (Utils_visiona.getBits(trailer.noBitLock, 1, 1) << 5) +
    (Utils_visiona.getBits(trailer.lockOut, 1, 1) << 4) +
    (Utils_visiona.getBits(trailer.wait, 1, 1) << 3) +
    (Utils_visiona.getBits(trailer.retransmit, 1, 1) << 2) +
    (Utils_visiona.getBits(trailer.farmBCount, 1, 2))
  end

  def flagsChanged?(vcid, newFlags)

    return true if @vcid_hk_flags[vcid].nil?
    return true if @vcid_hk_flags[vcid] != newFlags
    return false
  end

  def update_vcid_hk_flags(vcid, flags)

    @vcid_hk_flags[vcid] = flags
  end

  def handleCADUReport(trailer)

    array = Array.new
    bit64 = ((0x434f503156434900) + trailer.virtualChannelID)
    array64 = 64.downto(8).to_a
    (0..array64.length-1).step(8).each {|i| array << Utils_visiona.getBits(bit64, array64[i]-7, array64[i])}
    array << Utils_visiona.getBits(trailer.statusFields, 1, 3)
    array << Utils_visiona.getBits(trailer.noRFAvail, 1, 1)
    array << Utils_visiona.getBits(trailer.noBitLock, 1, 1)
    array << Utils_visiona.getBits(trailer.lockOut, 1, 1)
    array << Utils_visiona.getBits(trailer.wait, 1, 1)
    array << Utils_visiona.getBits(trailer.retransmit, 1, 1)
    array << Utils_visiona.getBits(trailer.farmBCount, 1, 2)
    array << Utils_visiona.getBits(trailer.reportValue, 1, 8)
    
    flags = getFlags(trailer)
    
    if @vcid_hk_timer[trailer.virtualChannelID].nil? || (Time.now > @vcid_hk_timer[trailer.virtualChannelID] + COP1_VCID_HK_PACKET_TIME) || flagsChanged?(trailer.virtualChannelID, flags)

      insert_into_buffer(array)
      @vcid_hk_timer[trailer.virtualChannelID] = Time.now
      update_vcid_hk_flags(trailer.virtualChannelID, flags)
    end
  end
end