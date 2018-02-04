# -----------------------------------------------------------------------------
# zendtodocker
#
# Builds a basic container that runs ZendTo
# -----------------------------------------------------------------------------

# Base system is CentOS 7
FROM    centos:centos7
MAINTAINER "ubellavance"
ENV container=docker \
	defaultEmailDomain="lubik.ca" \
	language="fr_FR" \
	serverRoot="zendto.lubik.ca" \
	SMTPserver="relais.videotron.ca" \
	SMTPport="25" \
	SMTPsecure="" \
	SMTPpassword="" \
	clamdscan="DISABLED" \
	ServiceTitle="ZendTo" \
	OrganizationShortName="Lubik" \
	OrganizationShortType="Organization" \
	EmailSenderAddress="ZendTo <zendto@lubik.ca" \
	EmailSubjectTag="[ZendTo] " \
	TIMEZONE="EST"

# Lets get the latest patches for CentOS

RUN yum -y install deltarpm

RUN yum clean all \
	&& yum update -y

# Install Nagios prereq's and some common stuff (we will get the epel release for the nagios install).
RUN yum install -y \
	less \
	httpd \
	mod_ssl \
	yum-utils \
	php \
	php-cli \
  	php-mbstring\
	php-pdo\
	mlocate \
  	which \
	htop

# Install yum repos

RUN yum -y install epel-release
RUN rpm -ivhf http://zend.to/files/zendto-repo.rpm

# Install ZendTo rpm

RUN yum -y install zendto

RUN yum clean all

# Configuration stage

RUN sed -i s/"OrganizationShortName = \"Southampton\""/"OrganizationShortName = \"$OrganizationShortName\""/g /opt/zendto/config/zendto.conf
RUN sed -i s/"OrganizationShortType = \"University\""/"OrganizationShortType = \"$OrganizationShortType\""/g /opt/zendto/config/zendto.conf

# Open ports for http/https/ntp
# 443 is for https
EXPOSE 443
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
