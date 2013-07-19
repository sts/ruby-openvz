Contributed Scripts
===================

vzdeploy
--------

A deployment script I use to setup new Debian containers.

<pre>
Usage: vzdeploy [options] ctid hostname ip\_address
    -i, --interface                  Use this interface name instead
    -b, --bridge                     Use this bridge pattern instead, specify either interface name or vlan id.
    -r, --release RELEASE            Specify the Debian release to bootstrap.
    -u, --upgrade                    Start and automatically upgrade the machine after bootstrap.
    -p, --puppet                     Install puppet into the container as well.
    -a, --architecture ARCH          Define the architecture used when bootstraping
        --venet                      Configure a venet interface instead of veth.
</pre>

The script will try to generate MAC addresses based on the following criteria:

On the host:   E2:00:00:00:11:11
On the client: F2:00:00:00:11:11

E2 is the prefix on the hardware node (outside the container), zeros are
substituded by the CTID (max 6 digits) and the ones are substituded with the
vlan-id. Your CTID is required to be globally unique in this setup.

The vlan-id is parsed from the name of the bridge, which the interface is going
to be attached to. (RTFS add\_interface and gen\_mac methods)

The recommended naming scheme:

 vzbreth0 ... bridged on eth0.
 vzbreth1 ... bridged on eth1.
 vzbrbond0 .. bridged on a bonded adapter.
 vzbr400 .... tagged vlan 400.

I'd be glad the see push requests for the easymac-style mac generation. ;-)


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
   vzctl set ctid --netif\_del ifname.
</pre>
