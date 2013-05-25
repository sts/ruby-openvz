Contributed Scripts
===================

vzdeploy
--------

A deployment script I use to setup new Debian containers.

<pre>
Usage: vzdeploy [options] ctid hostname ip_address
    -i, --interface                  Use this interface name instead
    -b, --bridge                     Use this bridge pattern instead, specify either interface name or vlan id.
    -r, --release RELEASE            Specify the Debian release to bootstrap.
    -u, --upgrade                    Start and automatically upgrade the machine after bootstrap.
    -p, --puppet                     Install puppet into the container as well.
    -a, --architecture ARCH          Define the architecture used when bootstraping
        --venet                      Configure a venet interface instead of veth.
</pre>


vznetcfg
--------

This script will automatically attach a veth interface to a bridge on container
start.


vzvethadd
---------

Used to add veth network interface to a container.

<pre>
Usage: vzvethadd ctid vlanid ifname
To add an eth0 to container 100211 which is bridged with vzbr400:
   vzvethadd 100211 400 eth0
To add an eth0 to container 100211 which is bridged with vzbreth0:
   vzvethadd 100211 eth0 eth0
To undo changes done by vzvethadd, run:
   vzctl set ctid --netif_del ifname.
</p-re>
