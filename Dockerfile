# -----------------------------------------------------------------------------
# zendtodocker
#
# Builds a basic container that runs ZendTo
# -----------------------------------------------------------------------------

# Base system is CentOS 7
FROM    centos:centos7
MAINTAINER "ubellavance"

# Let's get the latest patches for CentOS


RUN yum clean all \
	&& yum update -y

RUN yum -y install epel-release

# Install prereq's and some common stuff.
RUN yum install -y \
	top \
	clamav \
	less \
	htop \
	httpd \
	mlocate \
	php \
	php-cli \
  	php-mbstring\
	php-pdo\
	php-imap\
  	which \
	vim \
	yum-utils

# Install yum repos

RUN rpm -ivhf http://zend.to/files/zendto-repo.rpm

# Install ZendTo rpm

RUN yum -y install zendto

RUN yum clean all

# Configuration stage

# Define variables
ENV container=docker \
	#allowEmailPasscode="TRUE" \
	allowEmailPasscode="FALSE" \
	#allowEmailRecipients="TRUE" \
	allowEmailRecipients="FALSE" \
	#allowExternalUploads="TRUE" \
	allowExternalUploads="FALSE" \
	#bccExternalSender="FALSE" \
	bccExternalSender="TRUE" \
	#bccSender="FALSE" \
	bccSender="TRUE" \
# Disable virus scanning... Demo
	clamdscan="DISABLED" \
# Disable captcha, demo
	captcha="disabled" \
	defaultEmailDomain="lubik.ca" \
	#defaultEmailPasscode="TRUE" \
	defaultEmailPasscode="FALSE" \
	demouser="demouser1" \
	demopass="demopass1" \
	demoaddress="demo@domain.com" \
	demofullname="demofull1" \
	demoorg="demoorg1" \
	#emailSenderIP="TRUE" \
	emailSenderIP="FALSE" \
	#humanDownloads="TRUE" \
	humanDownloads="FALSE" \
	#language="en_US" \
	language="fr_FR" \
	libraryDirectory="NSSDROPBOX_DATA_DIR."library"" \
	#localIPSubnets="array('152.78','10.','192.168.')" \
	localIPSubnets="array('10.','192.168.')" \
	#maxBytesForChecksum="209715200" \
	maxBytesForChecksum="20971520" \
	#maxNoteLength="1000" \
	maxNoteLength="100" \
	#maxPickupFailures="50" \
	maxPickupFailures="5" \
	#maxSubjectLength="100" \
	maxSubjectLength="10" \
	
# 2GB
	#maxdropoffsize="21474836480" \
	maxdropoffsize="2147483648" \
	#maxeachfilesize="21474836480" \
	maxeachfilesize="2147483648" \
	#numberOfDaysToRetain="14" \
	numberOfDaysToRetain="12" \
	#requestTo="" \
	requestTo="tickets@domain.com" \
	#requestTTL="60480" \
	requestTTL="6048" \
	#serverRoot="http://zendto.soton.ac.uk/" \
	serverRoot="zendto.lubik.ca" \
	#showRecipsOnPickup="FALSE" \
	showRecipsOnPickup="TRUE" \
	SMTPserver="relais.videotron.ca" \
	SMTPport="25" \
	SMTPsecure="true" \
	SMTPusername="ugousername" \
	SMTPpassword="ugopassword" \
	#useRealProgressBar="TRUE" \
	useRealProgressBar="FALSE" \
	#usingLibrary="FALSE" \
	usingLibrary="TRUE" \
	#warnDaysBeforeDeletion="0" \
	warnDaysBeforeDeletion="1" \
	#wordlist="numbers" \
	wordlist="words" \
	

	ServiceTitle="ZendTo" \
	OrganizationShortName="Lubik" \
	OrganizationShortType="Organization" \
	EmailSenderAddress="ZendTo <zendto@lubik.ca" \
	EmailSubjectTag="[ZendTo] " \
	TIMEZONE="EST"

# Zendto


# Based on the variables defined in this Dockerfile
RUN cp /opt/zendto/config/zendto.conf /root/
RUN cp /opt/zendto/config/preferences.php /root/
RUN sed -i s/"^OrganizationShortName = .*"/"OrganizationShortName = \"$OrganizationShortName\""/g /opt/zendto/config/zendto.conf
RUN sed -i s/"^OrganizationShortType = .*"/"OrganizationShortType = \"$OrganizationShortType\""/g /opt/zendto/config/zendto.conf
RUN sed -i s/"^  'defaultEmailDomain' *=> '.*',"/"  'defaultEmailDomain' => '$defaultEmailDomain',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'serverRoot' *=> '.*',"/"  'serverRoot'           => '$serverRoot',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'numberOfDaysToRetain' *=> [0-9]*,"/"  'numberOfDaysToRetain' => $numberOfDaysToRetain,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'warnDaysBeforeDeletion' *=> [0-9]*,"/"  'warnDaysBeforeDeletion' => $warnDaysBeforeDeletion,"/g /opt/zendto/config/preferences.php
# Change max file size. PHP 5 is limited to 4 GB by the default anyway
RUN sed -i s/"^  'maxBytesForDropoff' *=> [0-9]*,.*"/"  'maxBytesForDropoff'   => $maxdropoffsize,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'maxBytesForFile' *=> [0-9]*,.*"/"  'maxBytesForFile'      => $maxeachfilesize,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'maxBytesForChecksum' *=> [0-9]*,.*"/"  'maxBytesForChecksum'      => $maxBytesForChecksum,"/g /opt/zendto/config/preferences.php

RUN sed -i s/"^  'language' *=> .*,"/"  'language'             => '$language',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'showRecipsOnPickup' *=> .*,"/"  'showRecipsOnPickup'   => $showRecipsOnPickup,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'useRealProgressBar' *=> .*,"/"  'useRealProgressBar'   => $useRealProgressBar,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'requestTTL' *=> .*,"/"  'requestTTL'   => $requestTTL,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'wordlist' *=> .*,"/"  'wordlist'   => '$wordlist',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'requestTo' *=> .*,"/"  'requestTo'   => '$requestTo',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'allowExternalUploads' *=> .*,"/"  'allowExternalUploads'   => $allowExternalUploads,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'maxNoteLength' *=> .*,"/"  'maxNoteLength'   => $maxNoteLength,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'maxSubjectLength' *=> .*,"/"  'maxSubjectLength'   => $maxSubjectLength,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'humanDownloads' *=> .*,"/"  'humanDownloads'   => $humanDownloads,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'maxPickupFailures' *=> .*,"/"  'maxPickupFailures'   => $maxPickupFailures,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'allowEmailRecipients' *=> .*,"/"  'allowEmailRecipients'   => $allowEmailRecipients,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'allowEmailPasscode' *=> .*,"/"  'allowEmailPasscode'   => $allowEmailPasscode,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'defaultEmailPasscode' *=> .*,"/"  'defaultEmailPasscode'   => $defaultEmailPasscode,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'emailSenderIP' *=> .*,"/"  'emailSenderIP'   => $emailSenderIP,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'bccSender' *=> .*,"/"  'bccSender'   => $bccSender,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'bccExternalSender' *=> .*,"/"  'bccExternalSender'   => $bccExternalSender,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPserver' *,=> '.*',"/"  'SMTPserver'   => '$SMTPserver',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPport' *=> [0-9]*,"/"  'SMTPport'     => $SMTPport,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPsecure' *=> .*,"/"  'SMTPsecure'   => '$SMTPsecure',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPusername' *=> .*,"/"  'SMTPusername' => '$SMTPusername',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPpassword' *=> .*,"/"  'SMTPpassword' => '$SMTPpassword',"/g /opt/zendto/config/preferences.php


# Disable captcha because it's a demo:

RUN sed -i s/"'captcha' => .*"/"'captcha' => '$captcha',"/g /opt/zendto/config/preferences.php

# httpd

RUN sed -i 's-/var/www/html-/opt/zendto/www-g' /etc/httpd/conf/httpd.conf
RUN sed -i 's-/var/www-/opt/zendto/www-g' /etc/httpd/conf/httpd.conf

# Create demo user
RUN (echo $demopass; echo $demopass) | /opt/zendto/bin/adduser.php /opt/zendto/config/preferences.php "$demouser" "$demoaddress" "$demofullname" "$demoorg" ""

# Todo: Configure or disable virus scanning

# Open ports for http/https/ntp
# 80 is for http
EXPOSE 80

## Volumes

# Config files
VOLUME /opt/zendto/config
# Templates
VOLUME /opt/zendto/templates
# Data (includes uploads and SQLite DB, plus other stuff)
VOLUME /var/zendto

ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
