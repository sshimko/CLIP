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
# $1 - key
# $2 - key password
# $3 - subject
# $4 - cert name
cert_gen() {
	certdir=$(mktemp -d)
	random_file=${certdir}/noise
	dd if=/dev/random of=${random_file} count=8192 bs=1
	certutil -S -k rsa -c "${CLIP_CA}" -n "${4}" -s ${3} -v ${DAYS} -t 'u,u,u' \
		 -d ${IPSECDIR} -g ${KEYSIZE} -Z SHA256 -z ${random_file} \
		 -f ${NSS_DB_PASSWD}
	rm -rf ${certdir}
}

#args
# $1 - name of the cert to export
# $2 - base name of the output file
cert_export() {
	certutil -L -d ${IPSECDIR} -f ${NSS_DB_PASSWD} -n "${CLIP_CA}" > ca.crt
	#Not ideal... but need someway of ensuring the user can actually import files
	P12_PASS=$gen_passwd
	echo ${P12_PASS} > ${2}.pass
	p12util -o ${2}.p12 -n ${2} -d ${IPSECDIR} -f ${NSS_DB_PASSWD} -W ${2}.pass
}
