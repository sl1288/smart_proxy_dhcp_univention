# frozen_string_literal: true

require 'smart_proxy_dhcp_univention/dhcp_univention_version'
require 'smart_proxy_dhcp_univention/plugin_configuration'

module Proxy::DHCP::Univention
  class Plugin < ::Proxy::Provider
    plugin :dhcp_univention, ::Proxy::DHCP::Univention::VERSION

    requires :dhcp, '>= 1.17'
    default_settings dcDomain: '',
                     dhcpServiceName: '',
                     ucsServer: ''

    validate_readable :lease_file

    load_classes ::Proxy::DHCP::Univention::PluginConfiguration
    load_dependency_injection_wirings ::Proxy::DHCP::Univention::PluginConfiguration

  end
end
