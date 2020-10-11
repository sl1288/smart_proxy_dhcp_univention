# Univention DHCP Smart Proxy plugin


This plugin adds a new DHCP provider for managing records in univention.

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

Additional you need to add an SSH key login to the theforeman-proxy user to login in the univention server.

## Configuration

To enable this DNS provider, edit `/etc/foreman-proxy/settings.d/dhcp.yml` and set:

    :use_provider: dhcp_univention

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/dhcp_univention.yml`

