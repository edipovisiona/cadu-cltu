require 'cosmos/interfaces/interface'
require 'cosmos/io/udp_sockets'
require 'cosmos/config/config_parser'

module Cosmos

  class VisionaInterface < UdpInterface

    def initialize(hostname,
      write_dest_port,
      read_port,
      write_src_port = nil,
      interface_address = nil,
      ttl = 128, # default for Windows
      write_timeout = 10.0,
      read_timeout = nil,
      bind_address = '0.0.0.0')

      super(hostname, write_dest_port, read_port, write_src_port, interface_address, ttl, write_timeout, read_timeout, bind_address)
    end

    def get_packet

      first = true

      loop do
        # Protocols may have cached data for a packet, so initially just inject a blank string
        # Otherwise we can hold off outputing other packets where all the data has already
        # been received
        if !first or @read_protocols.length <= 0
          # Read data for a packet
          data = read_interface()
          return nil unless data
        else
          data = ''
          first = false
        end

        # Potentially modify data
        @read_protocols.each do |protocol|
          data = protocol.read_data(data)
          return nil if data == :DISCONNECT # Disconnect handled by thread
          break if data == :STOP
        end
        next if (data == :STOP || data.nil? || data.empty?)

        # Will create a packet only if it's not null.
        packet = convert_data_to_packet(data)
        @read_count += 1

        # Potentially modify packet
        @read_protocols.each do |protocol|
          packet = protocol.read_packet(packet)
          return nil if packet == :DISCONNECT # Disconnect handled by thread
          break if packet == :STOP
        end
        next if packet == :STOP

        return packet
      end
    end

    # Retrieves the next packet from the interface.
    # @return [Packet] Packet constructed from the data. Packet will be
    # unidentified (nil target and packet names)
    def read

      raise "Interface not connected for read: #{@name}" unless connected? && read_allowed?
      begin

        return get_packet
      rescue Exception => err

        Logger.instance.error("Error reading from interface : #{@name}")
        disconnect()
        raise err
      end
    end

    # Modified rescue Timeout::Error to return "" so protocols can deliver
    # cached data again
    def read_interface

      data = @read_socket.read(@read_timeout)
      read_interface_base(data)
      return data
      rescue Timeout::Error
        return ''
      rescue IOError # Disconnected
        return nil
    end
  end
end