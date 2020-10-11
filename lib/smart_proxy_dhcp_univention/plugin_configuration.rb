# frozen_string_literal: true

module ::Proxy::DHCP::Univention
  class PluginConfiguration
    def load_classes
      require 'smart_proxy_dhcp_univention/dhcp_univention_main'
    end

    def load_dependency_injection_wirings(container, settings)

      container.dependency :dhcp_provider, (lambda do
        Proxy::DHCP::Univention::Provider.new(
          settings[:dcDomain],
          settings[:dhcpServiceName],
          settings[:ucsServer]
        )
      end)

    end
  end
end
