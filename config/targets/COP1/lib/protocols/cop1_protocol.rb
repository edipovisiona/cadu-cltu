require 'cosmos/interfaces/protocols/protocol'
require 'cltu/cltu'
require 'cop1_hkpacket'

module Cosmos

  # Protocol which permanently overrides an item value such that reading the
  # item returns the overriden value. Methods are prefixed with underscores
  # so the API can include the original name which calls out to these
  # methods. Clearing the override requires calling normalize_tlm.
  class Cop1Protocol < Protocol

    # @param allow_empty_data [true/false] Whether STOP should be returned on empty data
    def initialize(allow_empty_data = false)

      super(allow_empty_data)
      @timer = Time.now
    end

    def read_data(data)

      # Timing must be handled by COP1_HKPacket
      if data.empty?

        data = COP1_HKPacket.instance.pack
        data = data.nil? ? "" : data.pack('c*')
      end

      return data
    end

    # This function is executed before writing data
    def write_packet(packet)

      @packet_name = packet.target_name.upcase

      # commands related to CLTU are in CLTU Protocol
      if @packet_name.eql?(COP1_TARGET_NAME)
      end
      return packet
    end
  end
end