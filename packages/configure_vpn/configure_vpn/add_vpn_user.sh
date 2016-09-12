#! /bin/bash -e

#TODO source common variables from a script
. /usr/bin/vpn_funcs.sh

gen_cert_subj CLIENT_SUBJ
gen_random_word CONN_NAME
gen_passwd CLIENT_PASSWD
WORKDIR=/tmp/add_vpn_user

# arg1 is 1 for IKEV1 2 for IKEv2
if [ $1"x" != "1x" -a $1"x" != "2x" ]
then
	echo "invalid IKE parameter"
	exit -1
fi


mkdir -p $WORKDIR
cert_gen $CLIENT_PASSWD "$CLIENT_SUBJ" $CONN_NAME

XAUTH_INFO=""
XAUTH_USER=""
XAUTH_PASSWD=""

OUTDIR=/home/sftp/android_certs/
rm -rf $OUTDIR/*
CLIENT_PASSWD_FILE=$OUTDIR/client_pass.txt
XAUTH_INFO_FILE=$OUTDIR/xauth_info.txt
swan_config_gen $1 $CONN_NAME
xauth_gen $OUTDIR $CONN_NAME
cert_export $OUTDIR $CONN_NAME

echo $CLIENT_PASSWD > $CLIENT_PASSWD_FILE
if [ $1"x" == "1x" ]
then
	echo $XAUTH_USER > $XAUTH_INFO_FILE
	echo $XAUTH_PASSWD >> $XAUTH_INFO_FILE
fi
rm -rf $WORKDIR
chown -R sftp:sftp $OUTDIR
