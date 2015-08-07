module Spaceship
  module Portal
    # Represents a device from the Apple Developer Portal
    class Device < PortalBase
      # @return (String) The ID given from the developer portal. You'll probably not need it.
      # @example
      #   "XJXGVS46MW"
      attr_accessor :id

      # @return (String) The name of the device
      # @example
      #   "Felix Krause's iPhone 6"
      attr_accessor :name

      # @return (String) The UDID of the device
      # @example
      #   "4c24a7ee5caaa4847f49aaab2d87483053f53b65"
      attr_accessor :udid

      # @return (String) The platform of the device. This is probably always "ios"
      # @example
      #   "ios"
      attr_accessor :platform

      # @return (String) Status of the device. Probably always "c"
      # @example
      #   "c"
      attr_accessor :status

      attr_mapping({
        'deviceId' => :id,
        'name' => :name,
        'deviceNumber' => :udid,
        'devicePlatform' => :platform,
        'status' => :status
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @return (Array) Returns all devices registered for this account
        def all
          client.devices.map { |device| self.factory(device) }
        end

        # @return (Device) Find a device based on the ID of the device. *Attention*:
        #  This is *not* the UDID. nil if no device was found.
        def find(device_id)
          all.find do |device|
            device.id == device_id
          end
        end

        # @return (Device) Find a device based on the UDID of the device. nil if no device was found.
        def find_by_udid(device_udid)
          all.find do |device|
            device.udid == device_udid
          end
        end

        # @return (Device) Find a device based on its name. nil if no device was found.
        def find_by_name(device_name)
          all.find do |device|
            device.name == device_name
          end
        end

        # Register a new device to this account
        # @param name (String) (required): The name of the new device
        # @param udid (String) (required): The UDID of the new device
        # @example
        #   Spaceship.device.create!(name: "Felix Krause's iPhone 6", udid: "4c24a7ee5caaa4847f49aaab2d87483053f53b65")
        # @return (Device): The newly created device
        def create!(name: nil, udid: nil)
          # Check whether the user has passed in a UDID and a name
          unless udid && name
            raise "You cannot create a device without a device_id (UDID) and name"
          end

          # Find the device by UDID, raise an exception if it already exists
          if self.find_by_udid(udid)
            raise "The device UDID '#{udid}' already exists on this team."
          end

          # Find the device by name, raise an exception if it already exists
          if self.find_by_name(name)
            raise "The device name '#{name}' already exists on this team, use different one."
          end

          device = client.create_device!(name, udid)

          # Update self with the new device
          self.new(device)
        end
      end
    end
  end
end
