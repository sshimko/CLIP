# Copyright (C) 2012 Tresys Technology, LLC
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1) Distributed source includes this license and disclaimer,
# 2) Binary distributions must reproduce the license and disclaimer in the 
#    documentation and/or other materials provided with the distribution,
# 3) Tresys and contributors may not be used to endorse or promote products 
#    derived from this software without specific prior written permission
#
# THIS SOFTWARE IS PROVIDED BY TRESYS ``AS IS'' AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO 
# EVENT SHALL  TRESYS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#################### START CLIP CONFIGURATION ######################
# SEARCH THIS FILE FOR "FIXME" AND YOU WILL FIND THE FIELDS YOU
# NEED TO ADJUST.
#

# FIXME: Set your initial bootloader password below.
bootloader --location=mbr --timeout=5 --append="audit=1" --password=neutronbass

# FIXME: Change the root password.
#        CLIP locks the root account in the post below so this password won't 
#        work.  However, if the field is missing you will be prompted during 
#        installation for a password so specify one to avoid install-time 
#        questions.
# rootpw correctbatteryhorsestaple
rootpw neutronbass

lang en_US.UTF-8
keyboard us

#text - is broken bz 785400 anaconda abrt - No module named textw.netconfig_text
cdrom
install
timezone --utc Etc/GMT
auth --useshadow --passalgo=sha512

selinux --enforcing
firewall --enabled
reboot

# DO NOT REMOVE THE FOLLOWING LINE. NON-EXISTENT WARRANTY VOID IF REMOVED.
#REPO-REPLACEMENT-PLACEHOLDER

zerombr
clearpart --all --initlabel
part /boot --size=200 --fstype ext4 --asprimary
part pv.os --size=1   --grow        --asprimary

volgroup vg00 --pesize=65536 pv.os
logvol /              --vgname=vg00 --name=root  --fstype=ext4 --size 5500 --maxsize 21000 --grow
logvol /var           --vgname=vg00 --name=var   --fstype=ext4 --size 4000 --fsoptions=defaults,nosuid --grow
logvol /home          --vgname=vg00 --name=home  --fstype=ext4 --size=1    --fsoptions=defaults,nosuid,nodev --percent=80 --grow
logvol swap           --vgname=vg00 --name=swap  --fstype=swap --recommended

logvol /var/log       --vgname=vg00 --name=log   --fstype=ext4 --size 1500 --fsoptions=defaults,nosuid,noexec,nodev --maxsize 25000 --grow
logvol /var/log/audit --vgname=vg00 --name=audit --fstype=ext4 --size 1500 --fsoptions=defaults,nosuid,noexec,nodev --maxsize 25000 --grow
#logvol /tmp           --vgname=vg00 --name=tmp   --fstype=ext4 --size 100  --fsoptions=defaults,bind,nosuid,noexec,nodev --maxsize 6000  --grow
#logvol /var/tmp       --vgname=vg00 --name=vtmp  --fstype=ext4 --size 100  --fsoptions=defaults,nosuid,noexec,nodev --maxsize 5000  --grow
logvol /tmp           --vgname=vg00 --name=tmp   --fstype=ext4 --size 100  --maxsize 6000  --grow
logvol /var/tmp       --vgname=vg00 --name=vtmp  --fstype=ext4 --size 100  --maxsize 5000  --grow

%packages --excludedocs
@Base
clip-selinux-policy
# by default use MCS policy (clip-selinux-policy-clip)
-clip-selinux-policy-mls
clip-selinux-policy-mcs
clip-selinux-policy-mcs-ssh
clip-selinux-policy-mcs-unprivuser
clip-selinux-policy-mcs-ec2ssh
clip-selinux-policy-mcs-config-strongswan
clip-selinux-policy-mcs-vpnadm
clip-miscfiles
m4
scap-security-guide
dracut
clip-dracut-module

acl
aide
attr
audit
authconfig
basesystem
bash
bind-libs
bind-utils
chkconfig
configure_strongswan
coreutils
cpio
device-mapper
e2fsprogs
filesystem
glibc
initscripts
iproute
iptables
iptables-ipv6
iputils
kbd
kernel
ncurses
openscap
openscap-content
openscap-utils
openssh
openssh-server
passwd
perl
policycoreutils
policycoreutils-newrole
policycoreutils-python
procps
rootfiles
rpm
rsyslog
ruby
screen
-selinux-policy-targeted
setup
setools-console
shadow-utils
strongswan
sudo
util-linux-ng
vim-minimal
vlock
yum
-Red_Hat_Enterprise_Linux-Release_Notes-6-en-US
-abrt-addon-ccpp
-abrt-addon-kerneloops
-abrt-addon-python
-abrt-cli
-acpid
-alsa-utils
-authconfig
-b43-fwcutter
-b43-openfwwf
-blktrace
-bridge-utils
-cryptsetup-luks
-dbus
dhclient
-dmraid
-dosfstools
-fprintd
-fprintd-pam
-hicolor-icon-theme
-kexec-tools
-man
-man-pages
-man-pages-overrides
-mdadm
-mlocate
-mtr
-nano
-ntsysv
-pinfo
-postfix
-prelink
-psacct
-pm-utils
-redhat-indexhtml
-rdate
-readahead
-rhnsd
-setserial
-setuptool
-strace
-subscription-manager
-sysstat
-systemtap-runtime
-system-config-firewall-tui
-system-config-network-tui
-tcpdump
-traceroute
-vconfig
-virt-what
-wget
-yum-rhn-plugin

-libreport

-aic94xx-firmware
-at
-atmel-firmware
-bfa-firmware
-ipw2100-firmware
-ipw2200-firmware
-ivtv-firmware
-iwl100-firmware
-iwl1000-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-kernel-firmware
-libertas-usb8388-firmware
-ql2100-firmware
-ql2200-firmware
-ql23xx-firmware
-ql2400-firmware
-ql2500-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware

%end

%post --interpreter=/bin/bash
# DO NOT REMOVE THE FOLLOWING LINE. NON-EXISTENT WARRANTY VOID IF REMOVED.
#CONFIG-BUILD-PLACEHOLDER
export PATH="/sbin:/usr/sbin:/usr/bin:/bin:/usr/local/bin"
exec >/root/clip_post_install.log 2>&1
if [ x"$CONFIG_BUILD_LIVE_MEDIA" == "xy" ] \
	|| [ x"$CONFIG_BUILD_AWS" == "xy" ];
then
	# Print the log to tty7 so that the user know what's going on
	tail -f /root/clip_post_install.log >/dev/tty7 &
	TAILPID=$!
	chvt 7
fi


echo "Installation timestamp: `date`" > /root/clip-info.txt
echo "#CONFIG-BUILD-PLACEHOLDER" >> /root/clip-info.txt

export POLNAME=$(awk -F= '/^SELINUXTYPE/ { print $2; }' /etc/selinux/config)

#NOTE: while the following lines allow the SCAP content to be interprested on
# CentOS, the results might be wrong in a few places, like FIPS compliance and
# gpgp keys etc.
if [ -f /etc/centos-release ]; then
	awk '/o:redhat:enterprise_linux:6/{print "<platform idref=\"cpe:/o:centos:centos:6\"/>"}1' < /usr/share/xml/scap/ssg/content/ssg-rhel6-xccdf.xml > /usr/share/xml/scap/ssg/content/ssg-centos6-xccdf.xml
	xccdf='centos6'
else
	xccdf='rhel6'
fi

mkdir -p /root/scap/{pre,post}/html
oscap xccdf eval --profile stig-rhel6-server-upstream \
--report /root/scap/pre/html/report.html \
--results /root/scap/pre/html/results.xml \
/usr/share/xml/scap/ssg/content/ssg-${xccdf}-xccdf.xml

oscap xccdf generate fix \
--result-id xccdf_org.open-scap_testresult_stig-rhel6-server-upstream \
/root/scap/pre/html/results.xml > /root/scap/pre/remediation-script.sh

chmod +x /root/scap/pre/remediation-script.sh
if [ x"$CONFIG_BUILD_REMEDIATE" == "xy" ]; then
        mkdir -p /tmp/service
        echo "#!/bin/bash" > /tmp/service/service
        echo "echo \"ignoring service call \$1\" >> /tmp/service/service.log" >> /tmp/service/service
        chmod a+x /tmp/service/service
        PATH=/tmp/service:$PATH /root/scap/pre/remediation-script.sh
        # Un-remeidate things SSG broke...
        sed -i -e "s/targeted/${POLNAME}/" /etc/selinux/config
        cat /etc/issue | sed 's/\[\\s\\n\][+*]/ /g;s/\\//g;s/[^-]- /\n\n-/g' | fold -sw 80 > /etc/issue.net
        cp /etc/issue.net /etc/issue
fi


if [ x"$CONFIG_BUILD_AWS" != "xy" -o x"$CONFIG_BUILD_VPN_ENABLE_TOOR" == "xy" ]; then
	# FIXME: Change the username and password.
	#        If a hashed password is specified it will be used
	#        and the PASSWORD field will be ignored.
	#
	#        To generate a SHA512 hashed password try something like this:
	#           python -c "import crypt; print crypt.crypt('neutronbass', '\$6\$314159265358\$')"
	#        Note that the "\$6" indicates it is SHA512 and must remain in place.
	#        Further, make sure you specify a salt such as "314159265358."
	#        Finally, make sure the hashed password is in single quotes to prevent expansion of the dollar signs.
	USERNAME="toor"
	PASSWORD="neutronbass"
	HASHED_PASSWORD='$6$314159265358$ytgatj7CAZIRFMPbEanbdi.krIJs.mS9N2JEl0jkPsCvtwC15z07JLzFLSuqiCdionNZ1XNT3gPKkjIG0TTGy1'

	# NOTE: The root account is *locked*.  You must create an unprivileged user 
	#       and grant that user administrator capabilities through sudo.
	#       An account will be created below.  This account will be allowed to 
	#       change to the SELinux system administrator role, and become root via 
	#       sudo.  The information used to create the account comes from the 
	#       USERNAME and PASSWORD values defined a few lines above.
	#
	# Don't get lost in the 'if' statement - basically map $USERNAME to the unconfined toor_r:toor_t role if it is enabled.  
	if [ x"$CONFIG_BUILD_UNCONFINED_TOOR" == "xy" ]; then
		semanage user -N -a -R toor_r -R staff_r -R sysadm_r "${USERNAME}_u" 
	else
		semanage user -N -a -R staff_r -R sysadm_r "${USERNAME}_u" || semanage user -a -R staff_r "${USERNAME}_u"
	fi
	useradd -m "$USERNAME" -G wheel
	semanage login -N -a -s "${USERNAME}_u" "${USERNAME}"

	if [ x"$HASHED_PASSWORD" == "x" ]; then
		passwd --stdin "$USERNAME" <<< "$PASSWORD"
	else
		usermod --pass="$HASHED_PASSWORD" "$USERNAME"
	fi

	if [ x"$CONFIG_BUILD_AWS" != "xy" ]; then
		chage -d 0 "$USERNAME"
	fi
	
	# Add the user to sudoers and setup an SELinux role/type transition.
	# This line enables a transition via sudo instead of requiring sudo and newrole.
	if [ x"$CONFIG_BUILD_UNCONFINED_TOOR" == "xy" ]; then
		echo "$USERNAME        ALL=(ALL) ROLE=toor_r TYPE=toor_t      ALL" >> /etc/sudoers
	else
		echo "$USERNAME        ALL=(ALL) ROLE=sysadm_r TYPE=sysadm_t      ALL" >> /etc/sudoers
	fi
fi

# Lock the root acct to prevent direct logins
usermod -L root

# default network settings
if [ x"$CONFIG_BUILD_AWS" == "xy" -o x"$CONFIG_BUILD_ENABLE_DHCP" == "xy" ]; then
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp
IPV6_PRIVACY=rfc3041
EOF
fi

# Disable all that GUI stuff during boot so we can actually see what is going on during boot.
if [ -f '/boot/grub.conf' -a x"$CONFIG_BUILD_PRODUCTION" != "xy" ]; then
	# The first users of a CLIP system will be devs. Lets make things a little easier on them.
	# by getting rid of the framebuffer effects, rhgb, and quiet.
	grubby --update-kernel=ALL --remove-args="rhgb quiet"
	sed -i -e 's/^\(splashimage.*\)/#\1/' -e 's/^\(hiddenmenu.*\)/#\1/' /boot/grub/grub.conf
	# This is ugly but when plymouth re-rolls the initrd it creates a new entry in grub.conf that is redundant.
	# Actually rather benign but may impact developers using grubby who think there is only one kernel to work with.
	title="$(sed 's/ release.*$//' < /etc/redhat-release) ($(uname -r))"
	sed -i -e "s;title.*;title $title;" /boot/grub/grub.conf
	echo "Modifying splash screen with plymouth..."
	plymouth-set-default-theme details --rebuild-initrd &> /dev/null
fi

if [ x"$CONFIG_BUILD_ENFORCING_MODE" != "xy" ]; then
	echo "Setting permissive mode..."
	echo -e "#THIS IS A DEBUG BUILD HENCE SELINUX IS IN PERMISSIVE MODE\nSELINUX=permissive\nSELINUXTYPE=$POLNAME\n" > /etc/selinux/config
	echo "WARNING: This is a debug build in permissive mode.  DO NOT USE IN PRODUCTION!" >> /etc/motd
	# This line is used to make policy development easier.  It disables the "setfiles" check used by 
	# semodule/semanage that prevents transactions containing invalid and dupe fc entries from rolling forward.
	echo -e "module-store = direct\n[setfiles]\npath=/bin/true\n[end]\n" > /etc/selinux/semanage.conf
	if [ -f /etc/grub.conf ]; then
		grubby --update-kernel=ALL --remove-args=enforcing
		grubby --update-kernel=ALL --args=enforcing=0
	fi	
fi

# We don't want the final remediation script to set the system to targeted
sed -i -e "s/SELINUXTYPE=${POLNAME}/SELINUXTYPE=targeted/" /etc/selinux/config

oscap xccdf eval --profile stig-rhel6-server-upstream \
--report /root/scap/post/html/report.html \
--results /root/scap/post/html/results.xml \
/usr/share/xml/scap/ssg/content/ssg-${xccdf}-xccdf.xml

oscap xccdf generate fix \
--result-id xccdf_org.open-scap_testresult_stig-rhel6-server-upstream \
/root/scap/post/html/results.xml > /root/scap/post/remediation-script.sh
chmod +x /root/scap/post/remediation-script.sh

sed -i -e "s/targeted/${POLNAME}/" /etc/selinux/config

echo "session optional pam_umask.so umask=0077" >> /etc/pam.d/sshd


# Turn on IPV4 forwarding
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
sed -i 's/net.ipv4.ip_no_pmtu_disc = 0//' /etc/sysctl.conf
echo "net.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.conf

#####IPtables Configuration#####
cat << EOF > /etc/sysconfig/iptables
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A FORWARD -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -j MASQUERADE 
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT
-A INPUT -p udp -m udp --dport 500 -j ACCEPT
-A OUTPUT -p udp -m udp --sport 500 -j ACCEPT
-A INPUT -p udp -m udp --dport 4500 -j ACCEPT
-A OUTPUT -p udp -m udp --sport 4500 -j ACCEPT
COMMIT
EOF

#####IPtables End Configuration#####

# turn on the configure-strongswan service
chkconfig --level 34 configure-strongswan on

# Turn strongswan on in AWS as it will be configured by the scripts above.
chkconfig strongswan on

PASSWORD="neutronbass"
HASHED_PASSWORD='$6$314159265358$ytgatj7CAZIRFMPbEanbdi.krIJs.mS9N2JEl0jkPsCvtwC15z07JLzFLSuqiCdionNZ1XNT3gPKkjIG0TTGy1'

# we need to be vpnadm_u:vpnadm_r:vpnadm_t
useradd -m vpn
semanage user -N -a -R vpnadm_r vpnadm_u
semanage login -N -a -s vpnadm_u vpn
usermod -s /usr/bin/strongswan_login.py vpn
usermod --pass="$HASHED_PASSWD" 
chage -E -1 vpn

useradd -m sftp
semanage login -N -a -s vpnadm_u sftp
usermod -d /sftp sftp
#the above usermod line mucks up file_contexts.homedirs, fix it
semanage fcontext -a -e /sftp /home/sftp
usermod --pass="$HASHED_PASSWORD" sftp
chage -E -1 sftp

# Need to do some additional customizations if we're building for AWS
if [ x"$CONFIG_BUILD_AWS" == "xy" ]; then

	#set up /etc/ftsab
	sed -i -e "s/\/dev\/root/\/dev\/xvde1/" /etc/fstab
	mkdir -p /boot/grub

	#set up /boot/grub/menu.lst
	echo "default=0" >> /boot/grub/menu.lst
	echo -e "timeout=0\n" >> /boot/grub/menu.lst
	echo "title CLIP-KERNEL" >> /boot/grub/menu.lst
	echo "        root (hd0)" >> /boot/grub/menu.lst
	KERNEL=`find /boot -iname vmlinuz*`
	INITRD=`find /boot -iname initramfs*`
	echo "        kernel $KERNEL ro root=/dev/xvde1 rd_NO_PLYMOUTH" >> /boot/grub/menu.lst
	echo "        initrd $INITRD" >> /boot/grub/menu.lst

	# disable password auth
	sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

	# turn on the ssh key script
	chkconfig --level 34 ec2-get-ssh on

	# if you're the Government deploying to AWS and want to monitor people feel free to remove these lines.
	# But for our purposes, we explicitly don't want monitoring or logging
	> /etc/issue
	> /etc/issue.net
	#well logs are still useful for debugging purposes :)
	if [ x"$CONFIG_BUILD_VPN_ENABLE_TOOR" != "xy" ]
	then
                chkconfig rsyslog off
                chkconfig auditd off
                # TODO: this should really be done via policy
                # the #*/ makes vim highlighting normal again (or as normal as it is for a ks)
                rm -rf /var/log/* #*/
                touch /var/log/{yum.log,boot.log,secure,spooler,btmp,lastlog,utmp,wtmp,dmesg,maillog,messages,cron,audit/audit.log}
                chmod 000 /var/log/* #*/
                chattr +i /var/log/{yum.log,boot.log,secure,spooler,btmp,lastlog,utmp,wtmp,dmesg,maillog,messages,cron,audit/audit.log}
                rm -rf /root/* #*/
	fi

	SSH_USERS="sftp vpn"

	if [ x"$CONFIG_BUILD_VPN_ENABLE_TOOR" == "xy" ]
	then
		SSH_USERS="$SSH_USERS toor"
		chage -E -1 $USERNAME 
	fi
	sed -i -e "s/__USERS__/$SSH_USERS/g" /etc/rc.d/init.d/ec2-get-ssh

	cat << EOF > /etc/sysconfig/iptables
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A FORWARD -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1301:1536 -j TCPMSS --set-mss 1300
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -j MASQUERADE 
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A OUTPUT -p tcp -m tcp --sport 22 -j ACCEPT
-A INPUT -p udp -m udp --dport 500 -j ACCEPT
-A OUTPUT -p udp -m udp --sport 500 -j ACCEPT
-A INPUT -p udp -m udp --dport 4500 -j ACCEPT
-A OUTPUT -p udp -m udp --sport 4500 -j ACCEPT
-A INPUT -p tcp -m tcp --sport 80 -s 169.254.169.254 -j ACCEPT
-A OUTPUT -p tcp -m tcp --dport 80 -d 169.254.169.254 -j ACCEPT
COMMIT
EOF

elif [ x"$CONFIG_BUILD_LIVE_MEDIA" == "xy" ]; then
        chage -E -1 $USERNAME

else
	rpm -e clip-selinux-policy-mcs-ec2ssh
fi

sed -i -e 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e 's/#\s*RSAAuthentication .*/RSAAuthentication yes/' /etc/ssh/sshd_config
sed -i -e 's/#\s*PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i -e 's;.*AuthorizedKeysFile.*;AuthorizedKeysFile /home/%u/.ssh/authorized_keys;' /etc/ssh/sshd_config
sed -i -e 's/GSSAPIAuthentication .*/GSSAPIAuthentication no/g' /etc/ssh/sshd_config

#make sure you're using the internal sftp
sed -i -r -e "s/Subsystem\s*sftp.*//g" /etc/ssh/sshd_config

echo -e "Subsystem sftp internal-sftp\n" >> /etc/ssh/sshd_config
echo -e "Match Group sftp\n" >> /etc/ssh/sshd_config
echo -e "        AllowTCPForwarding no\n" >> /etc/ssh/sshd_config
echo -e "        X11Forwarding no\n" >> /etc/ssh/sshd_config
echo -e "        ChrootDirectory /home\n" >> /etc/ssh/sshd_config
echo -e "        ForceCommand internal-sftp\n" >> /etc/ssh/sshd_config

semanage boolean -N -S ${POLNAME} -m --on ssh_chroot_rw_homedirs

# This is rather unfortunate, but the remediation content 
# starts services, which need to be killed/shutdown if
# we're rolling Live Media.  First, kill the known 
# problems cleanly, then just kill them all and let
# <deity> sort them out.

if [ x"$CONFIG_BUILD_LIVE_MEDIA" == "xy" ] \
	|| [ x"$CONFIG_BUILD_AWS" == "xy" ]; then
	rm /.autorelabel
fi

kill $TAILPID 2>/dev/null 1>/dev/null
kill $(jobs -p) 2>/dev/null 1>/dev/null

%end

