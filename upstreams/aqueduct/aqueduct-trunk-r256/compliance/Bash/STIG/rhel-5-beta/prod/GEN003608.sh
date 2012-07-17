#Aqueduct - Compliance Remediation Content
#Copyright (C) 2011,2012  Vincent C. Passaro (vincent.passaro@gmail.com)
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor,
#Boston, MA  02110-1301, USA.

#!/bin/bash
######################################################################
#By Tummy a.k.a Vincent C. Passaro		                     #
#Vincent[.]Passaro[@]gmail[.]com				     #
#www.vincentpassaro.com						     #
######################################################################
#_____________________________________________________________________
#|  Version |   Change Information  |      Author        |    Date    |
#|__________|_______________________|____________________|____________|
#|    1.0   |   Initial Script      | Vincent C. Passaro | 20-oct-2011|
#|	    |   Creation	    |                    |            |
#|__________|_______________________|____________________|____________|
#
#
# - updated by Shannon Mitchell(shannon.mitchell@fusiontechnology-llc.com)
# on 04-feb-2012 to cut back on the output from sysctl -p.  Also added
# check for the default and all entries.

#######################DISA INFORMATION###############################
#Group ID (Vulid): V-22415
#Group Title: GEN003608
#Rule ID: SV-26628r1_rule
#Severity: CAT II
#Rule Version (STIG-ID): GEN003608
#Rule Title: Proxy ARP must not be enabled on the system.
#
#Vulnerability Discussion: Proxy ARP allows a system to respond to ARP requests on one interface on behalf of hosts connected to another interface. If this function is enabled when not required, addressing information may be leaked between the attached network segments.
#
#Responsibility: System Administrator
#IAControls: ECSC-1
#
#Check Content: 
#Check that the system does not use proxy ARP.
# cat /proc/sys/net/ipv4/conf/all/proxy_arp
#If the result is not 0, this is a finding.
#
#Fix Text: Configure the system to not use proxy ARP.
#Edit /etc/sysctl.conf and add a setting for "net.ipv4.conf.all.proxy_arp=0" and "net.ipv4.conf.default.proxy_arp=0".
# sysctl -p   
#######################DISA INFORMATION###############################

#Global Variables#
PDI=GEN003608
IPACKETS=$( cat /proc/sys/net/ipv4/conf/all/proxy_arp )
IPACKETSDEF=$( cat /proc/sys/net/ipv4/conf/default/proxy_arp )

#Start-Lockdown

if [ $IPACKETS -ne 0 ]
then
  echo " " >> /etc/sysctl.conf
  echo "#Added by STIG check $PDI" >> /etc/sysctl.conf
  echo "net.ipv4.conf.all.proxy_arp=0" >> /etc/sysctl.conf
  sysctl -p > /dev/null
fi

if [ $IPACKETSDEF -ne 0 ]
then
  echo " " >> /etc/sysctl.conf
  echo "#Added by STIG check $PDI" >> /etc/sysctl.conf
  echo "net.ipv4.conf.default.proxy_arp=0" >> /etc/sysctl.conf
  sysctl -p > /dev/null
fi
