#! /bin/bash -e

WORD_PROG=/usr/bin/gen_word.py
WORDS=`$WORD_PROG 50`
NEXT_WORD="\${WORD_ARRAY[WORD_INDEX]}; WORD_INDEX=\$[WORD_INDEX + 1]"
#Nickname used to reference CA
IPSECDIR=/etc/ipsec.d
SWAN_DB_URI=sql:$IPSECDIR
DAYS=1024
KEYSIZE=4096
CLIP_CA=CLIP-CA
NSS_DB_PASSWD=$IPSECDIR/nsspassword
SFTP_OUTDIR=/home/sftp/android_certs/
CA_PEM=$SFTP_OUTDIR/ca.pem
CLIENT_PASSWD_FILE=$SFTP_OUTDIR/client.pass
CLIENT_CERT_P12=$SFTP_OUTDIR/client.p12
XAUTH_INFO_FILE=$SFTP_OUTDIR/xauth_info.txt


declare -a WORD_ARRAY
WORD_INDEX=0
for w in $WORDS;
do
	WORD_ARRAY[$WORD_INDEX]=$w
	WORD_INDEX=$[WORD_INDEX + 1]
done
WORD_INDEX=0

#$1 is the variable to update
function gen_passwd() {
	eval PASS=$NEXT_WORD
	for i in {0..2};
	do
		eval PASS=$PASS-$NEXT_WORD
	done
	eval $1=$PASS
}

#$1 is the variable to update
function gen_cert_subj() {

	#Seems like this could be an issue if we collide with actual domains
	eval ORG=$NEXT_WORD
	eval USER=$NEXT_WORD
	eval DOMAIN=$NEXT_WORD
	#Filter out special characters may break cert creation
	ORG=$(echo ${ORG} | sed -e 's/[^A-Za-z]//g')
	DOMAIN=$(echo ${DOMAIN} | sed -e 's/[^A-Za-z]//g')
	USER=$(echo ${USER} | sed -e 's/[^A-Za-z]//g')
	DOMAIN=$DOMAIN.com
	EMAIL=$USER@$DOMAIN
	SUBJ="C=US,ST=Maryland,L=Columbia,O=${ORG},CN=${DOMAIN}"
	eval $1='$SUBJ'
}

#$1 is the variable to update
#get the next random word
function gen_random_word() {
	eval $1=$NEXT_WORD
}

# args:
# $1 - key password
# $2 - subject
# $3 - cert name
cert_gen() {
	certdir=$(mktemp -d)
	random_file=${certdir}/noise
	dd if=/dev/random of=${random_file} count=8192 bs=1
	certutil -S -k rsa -c "${CLIP_CA}" -n "${3}" -s ${2} -v ${DAYS} -t 'u,u,u' \
		 -d ${IPSECDIR} -g ${KEYSIZE} -Z SHA256 -z ${random_file} \
		 -f ${NSS_DB_PASSWD}
	rm -rf ${certdir}
}

#args
#1 ike type
#2 connection name
swan_config_gen() {
	if [ $1"x" == "1x" ]
	then
		CONN="conn ${2}\n\
		ike=aes256-sha1-modp1024!\n\
		esp=aes256-sha1!\n\
		ikev2=never\n\
		rightid=${2}\n\
		alsoflip=clip-server"

	else
		CONN="conn ${2}\n\
		ike=aes256-sha256-ecp384!\n\
		esp=aes256-aes128-sha384-sha256-ecp384-ecp256!\n\
		ikev2=insist\n\
		rightid=${2}\n\
		alsoflip=clip-server"
	fi
	echo -e "$CONN" >> ${IPSECDIR}/${2}.conf
}

#args
#1 connection name
xauth_gen() {
	XAUTH_INFO=""
	XAUTH_USER=""
	XAUTH_PASSWD=""
	gen_random_word XAUTH_USER
	gen_passwd XAUTH_PASSWD
	XAUTH_INFO=": RSA \"${1}\"\n@${XAUTH_USER} : XAUTH \"${XAUTH_PASSWD}\"\n"
	if [ "$XAUTH_INFO""x" != "x" ]
	then
		echo -e "$XAUTH_INFO" >> ${IPSECDIR}/${1}.secrets
	fi
	echo $XAUTH_USER > ${XAUTH_INFO_FILE}
	echo $XAUTH_PASSWD >> ${XAUTH_INFO_FILE}
	chown vpn:sftp ${XAUTH_INFO_FILE}; chmod 640 ${XAUTH_INFO_FILE}
}


#args
# $1 - name of the cert to export
cert_export() {
	#Convert to PEM
	certutil -L -d ${IPSECDIR} -f ${NSS_DB_PASSWD} -n "${CLIP_CA}" -r | openssl x509 -inform DER \
		-out ${CA_PEM} -outform PEM
	gen_passwd P12_PASS
	echo ${P12_PASS} > ${CLIENT_PASSWD_FILE}
	chown vpn:sftp ${CLIENT_PASSWD_FILE}; chmod 640 ${CLIENT_PASSWD_FILE}
	pk12util -o ${CLIENT_CERT_P12} -n ${1} -d ${IPSECDIR} -k ${NSS_DB_PASSWD} -w ${CLIENT_PASSWD_FILE}
	chown vpn:sftp ${CA_PEM}; chmod 640 ${CA_PEM}
	chown vpn:sftp ${CLIENT_CERT_P12}; chmod 640 ${CLIENT_CERT_P12}
}
