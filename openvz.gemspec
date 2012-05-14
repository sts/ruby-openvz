$: <<  File.expand_path('../lib', __FILE__)

require 'openvz'

Gem::Specification.new do |s|
    s.name              = 'openvz'
    s.version           = OpenVZ::VERSION
    s.date              = '2012-06-15'
    s.authors           = 'Stefan Schlesinger'
    s.email             = 'sts@ono.at'
    s.homepage          = 'http://github.com/sts/ruby-openvz'

    s.summary           = 'OpenVZ API'
    s.description       = 'OpenVZ is a container based virtualization for Linux. This API will
                           allow you to easily write tools to manipulate containers on a host.' 

    s.has_rdoc          = false

    s.extra_rdoc_files  = %w[COPYING]

    s.add_dependency    'systemu'

    s.files = Dir.glob("{**/**/**/**/*}")
end
