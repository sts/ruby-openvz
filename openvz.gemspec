Gem::Specification.new do |s|
    s.name              = 'openvz'
    s.version           = '1.4'
    s.date              = '2011-10-26'
    s.authors           = 'Stefan Schlesinger'
    s.email             = 'sts@ono.at'
    s.homepage          = 'http://github.com/sts/ruby-openvz'

    s.summary           = 'OpenVZ API'
    s.description       = 'OpenVZ is a container based virtualization for Linux. This API will
                           allow you to easily write tools to manipulate containers on a host.'

    s.extra_rdoc_files  = %w[COPYING]

    # = MANIFEST =
    s.files = %w[
        openvz.gemspec
        lib/openvz.rb
        lib/openvz/vendor
        lib/openvz/vendor/systemu
        lib/openvz/vendor/systemu/README.tmpl
        lib/openvz/vendor/systemu/gemspec.rb
        lib/openvz/vendor/systemu/install.rb
        lib/openvz/vendor/systemu/samples
        lib/openvz/vendor/systemu/samples/e.rb
        lib/openvz/vendor/systemu/samples/b.rb
        lib/openvz/vendor/systemu/samples/d.rb
        lib/openvz/vendor/systemu/samples/c.rb
        lib/openvz/vendor/systemu/samples/a.rb
        lib/openvz/vendor/systemu/samples/f.rb
        lib/openvz/vendor/systemu/gen_readme.rb
        lib/openvz/vendor/systemu/lib
        lib/openvz/vendor/systemu/lib/systemu.rb
        lib/openvz/vendor/systemu/a.rb
        lib/openvz/vendor/systemu/README
        lib/openvz/vendor/require_vendored.rb
        lib/openvz/vendor/load_systemu.rb
        lib/openvz/log.rb
        lib/openvz/inventory.rb
        lib/openvz/util.rb
        lib/openvz/vendor.rb
        lib/openvz/confighash.rb
        lib/openvz/container.rb
        lib/openvz/shell.rb
        lib/openvz.rb
    ]

end
