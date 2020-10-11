# frozen_string_literal: true

require File.expand_path('lib/smart_proxy_dhcp_univention/dhcp_univention_version', __dir__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dhcp_univention'
  s.version     = Proxy::DHCP::Univention::VERSION
  s.date        = Date.today.to_s
  s.license     = 'GPL-3.0'
  s.authors     = ['']
  s.email       = ['']
  s.homepage    = 'https://github.com/sl1288/smart_proxy_dhcp_univention'

  s.summary     = "univention DHCP provider plugin for Foreman's smart proxy"
  s.description = "univention DHCP provider plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']
end
