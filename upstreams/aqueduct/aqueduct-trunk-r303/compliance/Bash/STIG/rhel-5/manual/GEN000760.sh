#!/bin/bash

##########################################################################
#Aqueduct - Compliance Remediation Content
#Copyright (C) 2011,2012  
#  Vincent C. Passaro (vincent.passaro@gmail.com)
#  Shannon Mitchell (shannon.mitchell@fusiontechnology-llc.com)
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
##########################################################################

###################### Fotis Networks LLC ###############################
# By Vincent C. Passaro                                                 #
# Fotis Networks LLC	                                                #
# Vincent[.]Passaro[@]fotisnetworks[.]com                               #
# www.fotisnetworks.com	                                                #
###################### Fotis Networks LLC ###############################
#
#  _____________________________________________________________________
# |  Version |   Change Information  |      Author        |    Date    |
# |__________|_______________________|____________________|____________|
# |    1.0   |   Initial Script      | Vincent C. Passaro | 1-Aug-2012 |
# |          |   Creation            |                    |            |
# |__________|_______________________|____________________|____________|
#	                                                                  
   
	
#######################DISA INFORMATION##################################
# Group ID (Vulid): V-918
# Group Title: GEN000760
# Rule ID: SV-37314r1_rule
# Severity: medium
# Rule Version (STIG-ID): GEN000760
# Rule Title: Accounts must be locked upon 35 days of inactivity.
#
# Vulnerability Discussion: On some systems, accounts with disabled 
# passwords still allow access using rcp, remsh, or rlogin through 
# equivalent remote hosts.  All that is required is the remote host name 
# and the user name match an entry in a hosts.equiv file and have a .rhosts 
# file in the user directory.  Using a shell called /bin/false or /dev/null 
# (or an equivalent) will add a layered defense.

# Non-interactive accounts on the system, such as application accounts, may 
# be documented exceptions.
#
# Responsibility: System Administrator
# IAControls: IAAC-1
#
# Check Content:
#
# Indications of inactive accounts are those that have no entries in the 
# "last" log. Check the date in the "last" log to verify it is within the 
# last 35 days or the maximum numbers of days set by the site if more 
# restrictive. If an inactive account is not disabled via an entry in the 
# password field in the /etc/passwd or /etc/shadow (or equivalent), check 
# the /etc/passwd file to check if the account has a valid shell. 

# The passwd command can also be used to list a status for an account.  For 
# example, the following may be used to provide status information on each 
# local account:

# cut -d: -f1 /etc/passwd | xargs -n1 passwd -S

# If an inactive account is found not disabled, this is a finding.
#
# Fix Text: 
#
# All inactive accounts will have /sbin/nologin (or an equivalent), as 
# the default shell in the /etc/passwd file and have the password disabled. 
# Examine the user accounts using the "last" command. Note the date of last 
# login for each account. If any (other than system and application 
# accounts) exceed 35 days or the maximum number of days set by the site, 
# not to exceed 35 days, then disable the accounts using 
# system-config-users tool. Alternately place a shell field of 
# /sbin/nologin /bin/false or /dev/null in the passwd file entry for the 
# account.   
#######################DISA INFORMATION##################################
	
# Global Variables
PDI=GEN000760
	
# Start-Lockdown

#Admin should sort this out. 

