#!/usr/bin/env bash
#
# Puppetize a new host
#

set -e
APTKEY="/usr/bin/apt-key"
APTINSTALL="/usr/bin/apt-get install -y --force-yes"
APTUPDATE="/usr/bin/apt-get update"
PUPPETMASTER="puppet.example.com"


# ignore recommends
echo "APT::Install-Recommends \"true\";" > /etc/apt/apt.conf.d/99recommends
echo "APT::Install-Suggests \"true\";" >> /etc/apt/apt.conf.d/99recommends
echo "Aptitude::Recommends-Important \"false\";" >> /etc/apt/apt.conf.d/99recommends

# Install lsb-release to determine the os version.
if [ ! -x /usr/bin/lsb_release ] ; then
    echo "Installing required package: lsb-release" >> /var/log/puppetize.log
    $APTINSTALL lsb-release %>> /var/log/puppetize.log
fi

DISTRIBUTION=$(lsb_release -s -i| awk '{print tolower($0)}')
RELEASE=$(lsb_release -s -c| awk '{print tolower($0)}')

echo "Puppetizing $DISTRIBUTION/$RELEASE" >> /var/log/puppetize.log

if [[ $DISTRIBUTION = "debian" ]] ; then


    if [[ ${RELEASE} = "squeeze" || ${RELEASE} = "lenny" ]] ; then
	echo "deb http://ftp.at.debian.org/debian ${RELEASE} main contrib non-free" > /etc/apt/sources.list
	echo "deb http://security.debian.org ${RELEASE}/updates main contrib non-free" >> /etc/apt/sources.list
    elif [[ ${RELEASE} = "etch" ]] ; then
	echo "deb http://archive.debian.org/debian ${RELEASE} main contrib non-free" > /etc/apt/sources.list
	echo "deb http://archive.debian.org/debian-security ${RELEASE}/updates main contrib non-free" >> /etc/apt/sources.list
    else
	echo "Cannot puppetize this debian version."
	exit 1
    fi

    $APTUPDATE &>> /var/log/puppetize.log
    $APTINSTALL debian-archive-keyring  &>> /var/log/puppetize.log
    $APTKEY update &>> /var/log/puppetize.log
    $APTINSTALL puppet facter &>> /var/log/puppetize.log
else
    echo "Cannot puppetize this distribution."
    exit 1
fi

# Everything is installed at this point
# -> run the puppet agent.
puppet agent --waitforcert 10 --server=puppet.example.com

exit 0
