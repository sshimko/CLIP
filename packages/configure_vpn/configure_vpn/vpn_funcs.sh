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
#1 output directory
#2 connection name
xauth_gen() {
	gen_random_word XAUTH_USER
	gen_passwd XAUTH_PASSWD
	XAUTH_INFO="$XAUTH_USER : XAUTH $XAUTH_PASSWD"
	if [ "$XAUTH_INFO""x" != "x" ]
	then
		echo -e "$XAUTH_INFO" >> ${IPSECDIR}/${2}.secrets
	fi
	echo $XAUTH_USER > ${1}/xauth_info.txt
	echo $XAUTH_PASSWD >> ${1}/xauth_info.txt
}


#args
# $1 - name of the cert to export
# $2 - base name of the output file
cert_export() {
	#Convert to PEM
	certutil -L -d ${IPSECDIR} -f ${NSS_DB_PASSWD} -n "${CLIP_CA}" -r | openssl x509 -inform DER \
		-out ${1}/ca.pem -outform PEM
	P12_PASS=$gen_passwd
	echo ${P12_PASS} > ${1}/${2}.pass
	pk12util -o ${1}/${2}.p12 -n ${2} -d ${IPSECDIR} -k ${NSS_DB_PASSWD} -W ${1}/client_pass.txt
}
