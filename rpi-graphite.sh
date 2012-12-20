#!/bin/bash -ex

#####################
# Installs Graphite
#####################
#Graphite served from :8080
#Default is disabled
#Requires interaction: yes, admin name, password

#Install Function - Installs packages from repositories
install ()
{
	apt-get update #always do "sudo apt-get update" before installing from the (always free) software repositories.
	DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o DPkg::Options::=--force-confdef \
        -o DPkg::Options::=--force-confold \
        install $@
}

#pip install function
pips ()
{
	pip install $@
}

install apache2 \
	python-pip \
	python-cairo \
	python-django \
	python-django-tagging \
	libapache2-mod-wsgi \
	libapache2-mod-python \
	python-twisted \
	python-memcache \
	python-pysqlite2 \
	python-simplejson \
	memcached \
	python-cairo-dev \
	python-ldap \
	erlang-os-mon \
	erlang-snmp \
	rabbitmq-server \
	netcat

#install with pip
pips whisper carbon graphite-web

#apache2 site conf from web
wget https://raw.github.com/tmm1/graphite/master/examples/example-graphite-vhost.conf -O /etc/apache2/sites-available/graphite
#port 8080 instead of 80
sed -i 's|80|8080' /etc/apache2/sites-available/graphite
echo "Listen 8080" >> /etc/apache2/sites-available/graphite

#wsgi from example
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi

#carbon.conf from example
cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf

#storage schemas from example
cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf

#because docs say so
mkdir -p /etc/httpd/wsgi/

#Local settings from example
cp /opt/graphite/webapp/graphite/local_settings.py.example /opt/graphite/webapp/graphite/local_settings.py

#SyncDB - requires interaction
cd /opt/graphite/webapp/graphite && python manage.py syncdb

#set permissions
chown -R www-data:www-data /opt/graphite/storage

#enable mod_wsgi
a2enmod wsgi

#enable site
a2ensite graphite

#restart apache2
service apache2 reload
