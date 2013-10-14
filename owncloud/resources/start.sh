#!/bin/bash

# Create SSL certificates if they don't exist
if [ ! -f /etc/apache2/ssl/server.key ]; then
	mkdir -p /etc/apache2/ssl
	KEY=/etc/apache2/ssl/server.key
	DOMAIN="owc.jaymob.de"
	SUBJ="
C=DE
ST=Berlin
O=JayMob
localityName=Berlin
commonName=$DOMAIN
organizationalUnitName=
emailAddress=admin@jaymob.de
"
	openssl genrsa -des3 -out /etc/apache2/ssl/server.key -passout env:CERT_PASSPHRASE 2048
	openssl req -new -batch -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key $KEY -out /tmp/$DOMAIN.csr -passin env:CERT_PASSPHRASE 
	cp $KEY $KEY.orig
	openssl rsa -in $KEY.orig -out $KEY -passin env:CERT_PASSPHRASE
	openssl x509 -req -days 365 -in /tmp/$DOMAIN.csr -signkey $KEY -out /etc/apache2/ssl/server.crt
fi

# Add our hostname and Docker-allocated IP address into /etc/hosts
HOSTLINE=$(echo $(ip -f inet addr show eth0 | grep 'inet' | awk '{ print $2 }' | cut -d/ -f1) $(hostname) $(hostname -s))
echo $HOSTLINE >> /etc/hosts

/usr/bin/mysqld_safe &
/usr/sbin/apache2ctl -D FOREGROUND
