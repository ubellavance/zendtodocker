# -----------------------------------------------------------------------------
# zendtodocker
#
# Builds a basic container that runs ZendTo
# -----------------------------------------------------------------------------


# Base system is CentOS 7
FROM    centos:centos7
MAINTAINER "ubellavance"
ENV container=docker \
	SMTPserver="relais.videotron.ca" \
	SMTPport="25" \
	SMTPsecure="nagios" \
	SMTPpassword="nagios" \
	clamdscan="DISABLED" \
	ServiceTitle="ZendTo" \
	OrganizationShortName="Lubik" \
	OrganizationShortType="Organization" \
	EmailSenderAddress="ZendTo <zendto@lubik.ca" \
	EmailSubjectTag="[ZendTo] " \
	TIMEZONE="EST"

# Lets get the latest patches for CentOS
RUN yum clean all \
	&& yum update -y \
  && yum update clean

# Install Nagios prereq's and some common stuff (we will get the epel release for the nagios install).
RUN yum install -y \
	httpd \
	mod_ssl \
	yum-utils \
	php \
	php-cli \
  	php-mbstring\
	php-pdo\
	mlocate \
	vim-common \
	vim-enhanced \
	wget \
  	which \
	htop

CMD [ "/bin/bash", "-c", "/usr/sbin/httpd" ]

# Open ports for http/https/ntp
# 443 is for https
EXPOSE 443
# 80 is for http
EXPOSE 80

# Volumes

# Config files
VOLUME /opt/zendto/config
# Templates
VOLUME /opt/zendto/templates
# Data (includes uploads and SQLite DB, plus other stuff)
VOLUME /var/zendto
