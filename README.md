OpenVZ API
==========

OpenVZ is a container based virtualization for Linux. This API will allow you
to easily write tools to manipulate containers on a host.

USAGE
=====

Here are some examples on how you can use the API.

<pre>
container = OpenVZ::Container.new('110')
container.start
</pre>

UBC Access
----------

To get the current value of privvmpages you can use the config accessor.

<pre>
container = OpenVZ::Container.new('110')
puts container.config.privvmpages
</pre>

Also in case you would like to update a UBC, use the same config accessor.

<pre>
 container = OpenVZ::Container.new('110')
 container.config.kmemsize = '5505024:5872024'
</pre>

Inventory
---------

<pre>
 # Create an inventoy of all containers
 inventory = OpenVZ::Inventory.new()
 inventory.load
 # Print a certain containers configuration option
 inventory['110'].config.privvmpages
 # Restart
 inventory['110'].restart
</pre>


Provisioning
============

You can as well use the build in functions to provision a new container.

<pre>
 container = OpenVZ::Container.new('110')

 container.create( :ostemplate => 'centos-5-x86_64-minimal',
                   :config     => 'vps.basic' )

 container.start
</pre>


Debootstrapping Containers
-------------------------

If your host is running Debian and you want to bootstrap a new Debian container,
you do not have to use a template, just use debootstrap.

<pre>
 container = OpenVZ::Container.new('110')

 container.create( :ostemplate => 'debain-6.0-bootstrap',
                   :config     => 'vps.basic' )

 container.debootstrap( :dist   => 'squeeze',
                       :mirror => 'http://cdn.debian.net/debian' )

 container.set( :nameserver => '8.8.8.8',
                :ipadd      => '10.0.0.2',
                :hostname   => 'mia.ono.at' )

 container.start

 # Update the system
 container.command('aptitude update ; aptitude -y upgrade ; apt-key update')

 # Install puppet
 container.command('aptitude -o Aptitude::Cmdline::ignore-trust-violations=true -y install puppet')
</pre>

NOTE: You need to create an empty template for this to work. Here is how
you do that:

<pre>
 mkdir /tmp/empty-template
 # We need a file in the tarball since vzcreate barfs on empty tarballs
 touch /tmp/empty-template/BOOSTRAPPED
 tar -zc -C /tmp/empty-template . -f debian-6.0-bootstrap.tar
 gzip debian-6.0-bootstrap.tar
 mv debian-6.0-bootstrap.tar.gz /var/lib/vz/template/cache
</pre>


BUGS
====

For bugs or feature requests, please use the GitHub issue tracker.

https://github.com/sts/ruby-openvz/issues


WHO
===

Stefan Schlesinger / sts@ono.at / @stsonoat / http://sts.ono.at
