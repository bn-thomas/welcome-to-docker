FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

ENV USER heroes
ENV PASSWORD P@ssword123

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y wget xauth xvfb procps ssh policykit-1

RUN mkdir -pm755 /etc/apt/keyrings
RUN wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources
RUN dpkg --add-architecture i386 \
       && apt-get update -y \
       && apt-get install -y --install-recommends winehq-stable

RUN wget -O nomachine.deb "https://www.nomachine.com/free/linux/64/deb"
RUN dpkg -i nomachine.deb
RUN rm nomachine.deb

RUN useradd -m ${USER}

EXPOSE 4000

ADD startup.sh /startup.sh
ADD start-h3.sh /start-h3.sh

# Install Heroes 3 Complete from GOG manually inside docker or move .wine folder from another Linux machine via command below
ADD .wine /home/${USER}/.wine

RUN chown -R ${USER}:${USER} /home/${USER}
RUN chmod a+x /start-h3.sh /startup.sh

RUN echo "${USER}:${PASSWORD}" | chpasswd
CMD ["/startup.sh"]
