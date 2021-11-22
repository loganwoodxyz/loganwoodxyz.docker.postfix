#!/bin/bash

# configure postfix

function setup_conf_and_secret {
	postconf -e "relayhost = $MTP_HOST" \
		"smtp_sasl_auth_enable = yes" \
		"smtp_sasl_security_options = noanonymous" \
		"smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" \
		"smtp_use_tls = yes" \
		"smtp_tls_security_level = encrypt" \
		"smtp_tls_note_starttls_offer = yes" \
		"smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
	sed 's/^[^#]*.-o smtp_fallback_relay/#&/' /etc/postfix/master.cf >/etc/postfix/master.cf

	
    echo "$MTP_RELAY $MTP_USER:$MTP_PASS" > /etc/postfix/sasl_passwd
    postmap hash:/etc/postfix/sasl_passwd

    chown root:root /etc/postfix/sasl_passwd.db
    chmod 0600 /etc/postfix/sasl_passwd.db
}

if [ -z "$MTP_INTERFACES" ]; then
  postconf -e "inet_interfaces = all"
else
  postconf -e "inet_interfaces = $MTP_INTERFACES"
fi

if [ -n "$MTP_PROTOCOLS" ]; then
  postconf -e "inet_protocols = $MTP_PROTOCOLS"
fi

if [ -n "$MTP_HOST" ]; then
  postconf -e "myhostname = $MTP_HOST"
fi

if [ -n "$MTP_DESTINATION" ]; then
  postconf -e "mydestination = $MTP_DESTINATION"
fi

if [ -n "$MTP_BANNER" ]; then
  postconf -e "smtpd_banner = $MTP_BANNER"
fi

if [ -n "$MTP_RELAY_DOMAINS" ]; then
  postconf -e "relay_domains = $MTP_RELAY_DOMAINS"
fi

if [ -n "$MTP_RELAY" -a -n "$MTP_PORT" -a -n "$MTP_USER" -a -n "$MTP_PASS" ]; then
    setup_conf_and_secret
else
    postconf -e 'mynetworks = 127.0.0.1/32 192.168.0.0/16 172.16.0.0/12 172.17.0.0/16 10.0.0.0/8'
fi

if [ $(grep -c "^#header_checks" /etc/postfix/main.cf) -eq 1 ]; then
	sed -i 's/#header_checks/header_checks/' /etc/postfix/main.cf
        echo "/^Subject:/     WARN" >> /etc/postfix/header_checks
        postmap /etc/postfix/header_checks
fi

newaliases
