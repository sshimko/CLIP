#! /bin/bash -e

. /usr/bin/vpn_funcs.sh
# arg1 is 1 for IKEV1 2 for IKEv2
if [ $1"x" != "1x" -a $1"x" != "2x" ]
then
	echo "invalid IKE parameter"
	exit -1
fi

#Generate individual client parameters
IKE=${1}
gen_cert_subj CLIENT_SUBJ
gen_random_word CONN_NAME
gen_passwd CLIENT_PASSWD

#Genererate and store off client configs and credentials
cert_gen $CLIENT_PASSWD "$CLIENT_SUBJ" $CONN_NAME
swan_config_gen ${IKE} $CONN_NAME
xauth_gen $CONN_NAME
cert_export $CONN_NAME
