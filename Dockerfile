FROM centos:7
MAINTAINER JR Morgan <jr@shifti.us>

LABEL Vendor="CentOS7" \
      License=GPLv2 \
      Version=1.0

ENV POWERWALL_HOST="10.0.0.25"
ENV DATABASE="PowerwallData"

ADD powerwall.repo /etc/yum.repos.d/powerwall.repo
RUN yum -y install epel-release
RUN yum -y --setopt=tsflags=nodocs install \
	influxdb \
	telegraf \
	initscripts \
	urw-fonts \
	grafana

# Defaults for InfluxDB
ENV INFLUXDB_HTTP_ENABLED=true \
    INFLUXDB_HTTP_BIND_ADDRESS="127.0.0.1:8086" \
    INFLUXDB_HTTP_AUTH_ENABLED=false \
    INFLUXDB_HTTP_LOG_ENABLED=true

## InfluxDB stores data by default at /var/lib/influxdb/[data|wal]
## which should be mapped to a docker/podman volume for persistence

ADD powerwall.conf /etc/telegraf/telegraf.d/powerwall.conf
ADD graf_DS.yaml /etc/grafana/provisioning/datasources/graf_DS.yaml
ADD graf_DA.yaml /etc/grafana/provisioning/dashboards/graf_DA.yaml

RUN mkdir -p /var/lib/grafana/dashboards && chown grafana:grafana /var/lib/grafana/dashboards

EXPOSE 3000

ADD run.sh /opt/run.sh
RUN chmod -v +x /opt/run.sh
RUN export $(grep -v "#" /etc/sysconfig/grafana-server | cut -d= -f1)

ENV POWERWALL_LOCATION="lat=-29.77552&lon=151.12384"

CMD ["/opt/run.sh"]
