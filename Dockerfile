FROM amd64/debian:buster

COPY rootfs_prefix/ /usr/src/rootfs_prefix/
COPY sources.list.d/nonfree.list /etc/apt/sources.list.d/nonfree.list
COPY collectd.conf /etc/collectd/collectd.conf
COPY NAS-MIB.txt /usr/share/snmp/mibs/NAS-MIB.txt
COPY QTS-MIB.txt /usr/share/snmp/mibs/QTS-MIB.txt
COPY collectd.conf.d  /etc/collectd/collectd.conf.d
COPY modules  /etc/collectd/modules


RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && apt-get install --no-install-recommends -qy \
    collectd-core \
    collectd-utils \
    build-essential \
	snmp \
	snmp-mibs-downloader \
    libatasmart-dev \
    libmicrohttpd12 \
    libprotobuf-c-dev \
 && make -C /usr/src/rootfs_prefix/ \
 && apt-get -yq --purge remove build-essential \
 && apt-get -yq autoremove \
 && apt-get -yq clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*

ENV LD_PRELOAD=/usr/src/rootfs_prefix/rootfs_prefix.so

ENTRYPOINT ["/usr/sbin/collectd"]
CMD ["-f"]

LABEL org.opencontainers.image.source=https://github.com/slavik73/qnap-collectd
LABEL org.opencontainers.image.description="collectd for qnap on amd64 - prometheys added"
LABEL org.opencontainers.image.licenses=MIT

