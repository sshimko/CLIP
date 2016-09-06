#! /bin/bash -e

#TODO source common variables from a script

. /usr/bin/vpn_funcs.sh

gen_cert_subj CLIENT_SUBJ
gen_random_word CONN_NAME
gen_passwd CLIENT_PASSWD

WORKDIR=/tmp/add_vpn_user
CLIENT_KEY=$WORKDIR/$CONN_NAME.key
CLIENT_PEM=$WORKDIR/$CONN_NAME.pem
CLIENT_P12=$WORKDIR/$CONN_NAME.p12
CA_PEM=/etc/ipsec.d/cacerts/ca.pem
IPSEC_DIR=/etc/ipsec.d/
CA_KEY=/etc/ipsec.d/private/rootCA.key
CA_P12=/etc/ipsec.d/cacerts/ca.crt
CERTDIR=/etc/ipsec.d/certs/
PRIVATEDIR=/etc/ipsec.d/private
CA_PASSWD_FILE=$PRIVATEDIR/ca_pass.txt
CA_PASSWD=`cat $CA_PASSWD_FILE`
DAYS=1024
REQUEST=$WORKDIR/request.csr

# arg1 is 1 for IKEV1 2 for IKEv2
if [ $1"x" != "1x" -a $1"x" != "2x" ]
then
	echo "invalid IKE parameter"
	exit -1
fi


mkdir -p $WORKDIR
cert_gen $CLIENT_KEY $CLIENT_PASSWD "$CLIENT_SUBJ" $CLIENT_PEM
p12util -n "$CLIENT_SUBJ" -d $SWAN_DB_URI -W "$CLIENT_PASSWD" -o $CLIENT_P12
certutil -L -n "CLIP-CA" -d $SWAN_DB_URI -a > $CA_P12

XAUTH_INFO=""
XAUTH_USER=""
XAUTH_PASSWD=""

if [ $1"x" == "1x" ]
then
	CONN="conn $CONN_NAME\n\
        ike=aes256-sha1-modp1024!\n\
        esp=aes256-sha1!\n\
	ikev2=never\n"
	gen_random_word XAUTH_USER
	gen_passwd XAUTH_PASSWD

	XAUTH_INFO="$XAUTH_USER : XAUTH $XAUTH_PASSWD"
else
	CONN="conn $CONN_NAME\n\
        ike=aes256-sha256-ecp384!\n\
        esp=aes256-aes128-sha384-sha256-ecp384-ecp256!\n\
	ikev2=insist\n"
fi

echo -e "$CONN" >> /etc/ipsec.conf

if [ "$XAUTH_INFO""x" != "x" ]
then
	echo -e "$XAUTH_INFO" >> /etc/ipsec.secrets
fi

OUTDIR=/home/sftp/android_certs/
CLIENT_PASSWD_FILE=$OUTDIR/client_pass.txt
XAUTH_INFO_FILE=$OUTDIR/xauth_info.txt

rm -rf $OUTDIR
mkdir -p $OUTDIR
cp $CLIENT_P12 $OUTDIR
cp $CA_P12 $OUTDIR
echo $CLIENT_PASSWD > $CLIENT_PASSWD_FILE
if [ $1"x" == "1x" ]
then
	echo $XAUTH_USER > $XAUTH_INFO_FILE
	echo $XAUTH_PASSWD >> $XAUTH_INFO_FILE
fi
rm -rf $WORKDIR
chown -R sftp:sftp $OUTDIR

#restart strongswan
ipsec whack --rereadall
ipsec addconn --addall
