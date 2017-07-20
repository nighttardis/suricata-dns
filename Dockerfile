FROM debian:latest

LABEL maintainer nighttardis (nighttardis@user.noreply.github.com)

ENV SURICATA_VERSION 3.2.3
ENV SURICATA_PATH http://www.openinfosecfoundation.org/download/suricata-$SURICATA_VERSION.tar.gz
ENV BUILD_TOOLS "build-essential autoconf automake pkg-config"
ENV JAVA "openjdk-8-jre-headless ca-certificates-java"

RUN apt-get update && apt-get -y --no-install-recommends install apt-transport-https gnupg2 && \
 apt-get -y install wget && wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
 && echo "deb http://ftp.de.debian.org/debian jessie-backports main" >> /etc/apt/sources.list \
 && echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" >> /etc/apt/sources.list \
 && apt-get update && apt-get -y -t jessie-backports --no-install-recommends install $JAVA \
 && apt-get -y --no-install-recommends install libpcre3 libpcre3-dbg libpcre3-dev \
 libtool libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev zlib1g zlib1g-dev \
 libmagic-dev libcap-ng-dev libjansson-dev supervisor logrotate logstash $BUILD_TOOLS \
 && wget $SURICATA_PATH && tar -xzf suricata-$SURICATA_VERSION.tar.gz && cd suricata-$SURICATA_VERSION \
 && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make && make install && make install-conf  && ldconfig \
 && cd .. && rm -rf suricata-$SURICATA_VERSION.tar.gz && rm -rf suricata-$SURICATA_VERSION \
 && apt-get remove --purge -y $BUILD_TOOLS apt-transport-https wget gnupg2 && apt-get -y autoremove

ADD ./suricata.yaml /etc/suricata/suricata.yaml
ADD ./supervisor.conf /etc/supervisor/conf.d/
ADD ./suricata_rotate.conf /etc/logrotate.d/suricata_rotate.conf
ADD ./crontab /etc/cron.d/suricata_logrotate
RUN chmod 0644 /etc/cron.d/suricata_logrotate
ADD ./logstash /logstash
ADD ./elasticsearch /elasticsearch

#ENTRYPOINT [ "/bin/bash" ]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
