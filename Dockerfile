# Docker version 1.9.1
#
# To build: docker build --force-rm=true -t visualjeff/couchdb:latest .
# To run:   docker run -d -p 5984:5984 --name=my_cheezymail visualjeff/couchdb:latest

FROM    ubuntu:14.04
MAINTAINER Jeffrey Gilbert <jgilber@costco.com>
ENV DEBIAN_FRONTEND noninteractive

USER root

# Install dependencies
RUN apt-get update && apt-get dist-upgrade -y

# Install COUCHDB
RUN add-apt-repository ppa:couchdb/stable -y;apt-get update -y;apt-get remove couchdb couchdb-bin couchdb-common -yf;apt-get install -yV couchdb;mkdir -p /var/run/couchdb

# All outside addresses to access couchdb
RUN sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /etc/couchdb/default.ini;
RUN sed -e 's/enable_cors = false$/enable_cors = true/' -i /etc/couchdb/default.ini;
#RUN sed -e 's/database_dir = \/var\/lib\/couchdb/database_dir = \/data/' -i /etc/couchdb/default.ini;
RUN echo "" >> /etc/couchdb/default.ini;
RUN echo "[cors]" >> /etc/couchdb/default.ini;
RUN echo "origins = *" >> /etc/couchdb/default.ini;
RUN echo "methods = GET, PUT, POST, HEAD, DELETE" >> /etc/couchdb/default.ini;
RUN echo "headers = accept, authorization, content-type, origin, referer" >> /etc/couchdb/default.ini

# Add production or dist version (minified & finger printed) of your application.
WORKDIR /root

# Create the guest mount for external couchdb data storage, configs and logs.
#VOLUME ["/var/lib/couchdb"]
#VOLUME ["/etc/couchdb"]
#VOLUME ["/var/log/couchdb"]

# Expose ports
EXPOSE 5984

# Add in supervisor configs.
ADD ./supervisord.conf /usr/local/etc/supervisord.conf

# Do a little housekeeping to trim down the image size
RUN apt-get clean;apt-get autoclean;apt-get autoremove -y;rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# Start supervisor
CMD ["/usr/local/bin/supervisord", "-c", "/usr/local/etc/supervisord.conf"]
