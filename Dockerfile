# -----------------------------------------------------------------------------
# zendtodocker
#
# Builds a basic container that runs ZendTo
# -----------------------------------------------------------------------------

# Base system is CentOS 7
FROM    centos:centos7
MAINTAINER "ubellavance"

# Lets get the latest patches for CentOS


RUN yum clean all \
	&& yum update -y

# Install Nagios prereq's and some common stuff (we will get the epel release for the nagios install).
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

RUN yum -y install epel-release
RUN rpm -ivhf http://zend.to/files/zendto-repo.rpm

# Install ZendTo rpm

RUN yum -y install zendto

RUN yum clean all

# Configuration stage

# Define variables
ENV container=docker \
	defaultEmailDomain="lubik.ca" \
	language="fr_FR" \
	serverRoot="zendto.lubik.ca" \
	SMTPserver="relais.videotron.ca" \
	SMTPport="25" \
	SMTPsecure="true" \
	SMTPusername="ugousername" \
	SMTPpassword="ugopassword" \
	clamdscan="DISABLED" \
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
RUN /bin/sed -i s/"^  'defaultEmailDomain' *=> '.*',"/"  'defaultEmailDomain'   => '$defaultEmailDomain',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPserver' *,=> '.*',"/"  'SMTPserver'   => '$SMTPserver',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPport' *=> [0-9]*,"/"  'SMTPport'     => $SMTPport,"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPsecure' *=> .*,"/"  'SMTPsecure'   => '$SMTPsecure',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPusername' *=> .*,"/"  'SMTPusername' => '$SMTPusername',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'SMTPpassword' *=> .*,"/"  'SMTPpassword' => '$SMTPpassword',"/g /opt/zendto/config/preferences.php
RUN sed -i s/"^  'language' *=> .*,"/"  'language'             => '$language',"/g /opt/zendto/config/preferences.php

# Disable captcha because it's a demo:

RUN sed -i s/"'captcha' => .*"/"'captcha' => 'disabled',"/g /opt/zendto/config/preferences.php

# httpd

RUN sed -i 's-/var/www/html-/opt/zendto/www-g' /etc/httpd/conf/httpd.conf
RUN sed -i 's-/var/www-/opt/zendto/www-g' /etc/httpd/conf/httpd.conf

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
