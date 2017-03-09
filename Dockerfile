FROM ubuntu

#VOLUME ["/tsmusic"]

ENV TSBOT_URL https://frie.se/ts3bot/ts3soundboardbot-0.9.5.tar.bz2
ENV TEAMSPEAK_URL http://dl.4players.de/ts/releases/3.0.18.2/TeamSpeak3-Client-linux_amd64-3.0.18.2.run

# Download TS3 file and extract it into /opt.
ADD ${TSBOT_URL} /opt/
RUN cd /opt && tar -jxvf /opt/ts3soundboardbot*.tar.bz2

ADD ${TEAMSPEAK_URL} /opt/ts3soundboard/
RUN cd /opt/ts3soundboard && chmod 0755 TeamSpeak3-Client-linux_amd64-3.0.18.2.run
RUN sed -i 's/^MS_PrintLicense$//' /opt/ts3soundboard/TeamSpeak3-Client-linux_amd64-3.0.18.2.run
RUN cd /opt/ts3soundboard && ./TeamSpeak3-Client-linux_amd64-3.0.18.2.run

# Install prerequisites
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install x11vnc xinit xvfb libxcursor1 libglib2.0-0 xorg openbox wget
RUN wget -O "/usr/local/bin/youtube-dl" "https://yt-dl.org/downloads/latest/youtube-dl" && \
chmod a+rx "/usr/local/bin/youtube-dl" && \
locale-gen --purge en_US.UTF-8 && \
echo LC_ALL=en_US.UTF-8 >> /etc/default/locale && \
echo LANG=en_US.UTF-8 >> /etc/default/locale && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
groupadd -g 3000 -r "ts3soundboard" && \
useradd -u 3000 -r -g "ts3soundboard" -d "/opt/ts3soundboard" "ts3soundboard"

# Copy the plugin into the client and update the bot
RUN cp /opt/ts3soundboard/libsoundbot_plugin.so /opt/ts3soundboard/TeamSpeak3-Client-linux_amd64/plugins
RUN chown -R ts3soundboard /opt/ts3soundboard && \
chmod 755 /opt/ts3soundboard/ts3bot
RUN /opt/ts3soundboard/ts3bot -update

# Add a startup script
ADD run.sh /run.sh
RUN chmod 755 /*.sh

EXPOSE 8087
CMD ["chmod 775 run.sh"]
CMD ["/run.sh"]
