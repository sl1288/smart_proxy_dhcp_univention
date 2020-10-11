# frozen_string_literal: true

require 'fileutils'
require 'tempfile'
require 'dhcp_common/server'
#require 'dhcp_common/subnet_service'
require 'dhcp_common/subnet'

module Proxy::DHCP::Univention
  class Provider < ::Proxy::DHCP::Server

    def initialize(dcDomain, dhcpServiceName, ucsServer)
      @setting_dcDomain = dcDomain
      @setting_dhcpServiceName = dhcpServiceName
      @setting_ucsServer = ucsServer

      super('Univention',nil,nil)
    end

    def subnets
      logger.info "subnets"
    end

    def load_subnet_options(subnet)
      logger.info "load_subnet_options; #{subnet}"
    end

    def find_subnet(address)
      logger.info "find_subnet; #{address}"
      ::Proxy::DHCP::Subnet.new(address, '255.255.255.0')
    end

    def get_subnet(subnet_address)
      logger.info "get_subnet; #{subnet_address}"
      ::Proxy::DHCP::Subnet.new(subnet_address, '255.255.255.0')
    end

    def all_leases(subnet_address)
      logger.info "all_leases; #{subnet_address}"
    end

    def all_hosts(subnet_address)
      logger.info "all_hosts; #{subnet_address}"
    end

    def find_record(subnet_address, an_address)
      logger.info "find_record; #{subnet_address} / #{an_address}"
      records_by_ip = find_records_by_ip(subnet_address, an_address)
      return records_by_ip.first unless records_by_ip.empty?
      find_record_by_mac(subnet_address, an_address)
    end

    def find_record_by_mac(subnet_address, mac_address)
      logger.info "find_record_by_mac; #{subnet_address}; #{mac_address}"

      hostString = `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host list --filter "hwaddress=ethernet #{mac_address}"'`
      logger.info "hostString #{hostString}"

      if hostString =~ /fixedaddress: (\d+\.\d+\.\d+\.\d+)/
              ipaddress = $1
              logger.info "Found ip #{ipaddress} for mac #{mac_address}"
              return Proxy::DHCP::Reservation.new("", ipaddress, mac_address, Proxy::DHCP::Subnet.new(subnet_address,"255.255.255.0"))
      end

      nil
    end

    def find_records_by_ip(subnet_address, ip)
      logger.info "find_records_by_ip; #{subnet_address}; #{ip}"

      hostString = `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host list --filter "fixedaddress=#{ip}"'`
      logger.info "hostString #{hostString}"
      record = nil

      if hostString =~ /hwaddress: ethernet (.+)/
              mac_address = $1
              logger.info "Found mac #{mac_address} for ip #{ip}"
              return [ Proxy::DHCP::Reservation.new("", ip, mac_address, Proxy::DHCP::Subnet.new(subnet_address,"255.255.255.0")) ]
      end

      nil
    end

    def del_records_by_ip(subnet_address, ip)
      logger.info "del_records_by_ip; #{subnet_address} / #{ip}"
      records = find_records_by_ip(subnet_address, ip)
      records.each { |record| del_record(record) }
      nil
    end

    def del_record_by_mac(subnet_address, mac_address)
      logger.info "del_record_by_mac; #{subnet_address} / #{mac_address}"
      record = find_record_by_mac(subnet_address, mac_address)
      del_record(record) unless record.nil?
    end

    def unused_ip(subnet_address, mac_address, from_address, to_address)
      logger.info "unused_ip; #{subnet_address} / #{mac_address} / #{from_address} / #{to_address}"
      nil
    end

    def find_ip_by_mac_address_and_range(subnet, mac_address, from_address, to_address)
      logger.info "find_ip_by_mac_address_and_range; #{subnet} / #{mac_address} / #{from_address} / #{to_address}"
      nil
    end

    def add_record(options = {})
      logger.info "Adding record; #{options}"

      macName = options[:mac].gsub(/:/,"")

      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm policies/dhcp_boot create --position "cn=boot,cn=dhcp,cn=policies,#{@setting_dcDomain}" --set name="policy-#{macName}" --set boot_server="#{options[:nextServer]}"   --set boot_filename="#{options[:filename]}"' 2>&1`
      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host create --superordinate "cn=#{@setting_dhcpServiceName},cn=dhcp,#{@setting_dcDomain}" --set host="host-#{macName}" --set hwaddress="ethernet #{options[:mac]}" --set fixedaddress="#{options[:ip]}"' 2>&1`
      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host modify --dn "cn=host-#{macName},cn=#{@setting_dhcpServiceName},cn=dhcp,#{@setting_dcDomain}" --policy-reference "cn=policy-#{macName},cn=boot,cn=dhcp,cn=policies,#{@setting_dcDomain}"' 2>&1`
      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host modify --dn "cn=host-#{macName},cn=#{@setting_dhcpServiceName},cn=dhcp,#{@setting_dcDomain}" --policy-reference "cn=default-settings,cn=dns,cn=dhcp,cn=policies,#{@setting_dcDomain}"' 2>&1`
      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host modify --dn "cn=host-#{macName},cn=#{@setting_dhcpServiceName},cn=dhcp,#{@setting_dcDomain}" --policy-reference "cn=default-settings,cn=routing,cn=dhcp,cn=policies,#{@setting_dcDomain}"' 2>&1`

      logger.info "end"
      Proxy::DHCP::Record.new(options[:ip], options[:mac], Proxy::DHCP::Subnet.new(options[:network],"255.255.255.0"))
    end

    def find_similar_records(subnet_address, ip_address, mac_address)
      logger.info "find_similar_records; #{subnet_address} / #{ip_address} / #{mac_address}"
      nil
   end

   def clean_up_add_record_parameters(in_options)
     logger.info "clean_up_add_record_parameters; #{in_options}"
     nil
  end

  def vendor_options_included?(options)
    logger.info "vendor_options_included; #{options}"
    !options.keys.grep(/^</).empty?
  end

  def vendor_options_supported?
    logger.info "vendor_options_supported;"
    false
  end

  def managed_subnet?(subnet)
    logger.info "managed_subnet; #{subnet}"
     true
   end

    def del_record(record)
      logger.info "Deleting record; #{record} ; #{record[:mac]}"
      # No Removal of leases
      return record if record.is_a? ::Proxy::DHCP::Lease

      macName = record.mac.gsub(/:/,"")

      logger.info "Remove 'cn=host-#{macName},cn=#{@setting_dhcpServiceName},cn=dhcp,#{@setting_dcDomain}'"
      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm dhcp/host remove --dn "cn=host-#{macName},cn=#{@setting_dhcpServiceName},cn=dhcp,#{@setting_dcDomain}"'  2>&1`

      logger.info "Remove 'cn=policy-#{macName},cn=boot,cn=dhcp,cn=policies,#{@setting_dcDomain}'"
      logger.info `ssh -q -o BatchMode=yes -o StrictHostKeyChecking=no #{@setting_ucsServer} 'udm policies/dhcp_boot remove --dn "cn=policy-#{macName},cn=boot,cn=dhcp,cn=policies,#{@setting_dcDomain}"'  2>&1`

      record
    end



  end
end
