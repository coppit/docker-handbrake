FROM hurricane/dockergui:xvnc
#FROM hurricane/dockergui:x11rdp
#FROM hurricane/dockergui:xvnc

MAINTAINER David Coppit <david@coppit.org>

ENV APP_NAME="HandBrake" WIDTH=1280 HEIGHT=720 TERM=xterm

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

RUN \

# Speed up APT
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \

mkdir /files

# Add local files
COPY dpkg-excludes monitor.sh convert.sh start.sh HandBrake.conf.default /files/
COPY startapp.sh /

RUN \

# Revision-lock to a specific version to avoid any surprises.
wget -O /files/runas.sh \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/1401a636bbc9369141d0d32ac7b80c2bf7fcdbcb/runas.sh' && \
wget -O /files/monitor.py \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/1401a636bbc9369141d0d32ac7b80c2bf7fcdbcb/monitor.py' && \

mkdir /etc/service/monitor && \
mv /files/monitor.sh /etc/service/monitor/run && \
chmod +x /etc/service/monitor/run && \
mv /files/start.sh /etc/my_init.d && \
chmod +x /etc/my_init.d/start.sh && \

# repositories
echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe restricted' > /etc/apt/sources.list && \
echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates main universe restricted' >> /etc/apt/sources.list && \
add-apt-repository ppa:stebbins/handbrake-releases && \

# update apt and install dependencies
mv /files/dpkg-excludes /etc/dpkg/dpkg.cfg.d/excludes && \
apt-get update && \
apt-get install -qy handbrake-gtk handbrake-cli gnome-themes-standard && \

# install watchdog module for Python3
apt-get install -qy python3-setuptools && \
easy_install3 watchdog && \

# clean up
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))

# Set the locale, to support files that have non-ASCII characters
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

VOLUME ["/media", "/watch", "/output", "/config"]

EXPOSE 3389 8080
