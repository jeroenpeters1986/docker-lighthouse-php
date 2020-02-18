# Run Lighthouse w/ Chrome Headless in a container
#
# Lighthouse is a tool that allows auditing, performance metrics, and best
# practices for Progressive Web Apps.
#
# Based on the work of Justin Ribeiro <justin@justinribeiro.com>
#
# What's New
#
# 1. Allows cache busting so you always get the latest lighthouse.
# 1. Pulls from Chrome M59+ for headless support.
# 2. You can now use the ever-awesome Jessie Frazelle seccomp profile for Chrome.
#     wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome.json
#
#
# To run (without seccomp):
# docker run -it ~/your-local-dir:/opt/reports --net host justinribeiro/lighthouse
#
# To run (with seccomp):
# docker run -it ~/your-local-dir:/opt/reports --security-opt seccomp=$HOME/chrome.json --net host justinribeiro/lighthouse
#

FROM debian:buster-slim
LABEL name="lighthouse-php" \
  maintainer="Jeroen Peters <jeroenpeters1986@gmail.com>" \
  version="0.1" \
  description="Lighthouse analyzes web apps and web pages, collecting modern performance metrics and insights on developer best practices."

# MySQL root password
ARG MYSQL_ROOT_PASS=root

# Cloudflare DNS
RUN echo "nameserver 1.1.1.1" | tee /etc/resolv.conf > /dev/null

# Install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    unzip \
    mcrypt \
    wget \
    curl \
    openssl \
    ssh \
    locales \
    less \
    composer \
    sudo \
    mariadb-server \
    npm
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https lsb-release ca-certificates
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN EBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    php-pear php7.2-mysql php7.2-zip php7.2-xml php7.2-mbstring php7.2-curl php7.2-json php7.2-pdo php7.2-tokenizer php7.2-cli php7.2-imap php7.2-intl php7.2-gd php7.2-xdebug php7.2-soap php7.2-gmp apache2 libapache2-mod-php7.2 --no-install-recommends && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/lib/mysql/ib_logfile*

# Ensure UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Timezone & memory limit
RUN echo "date.timezone=Europe/Amsterdam" > /etc/php/7.2/cli/conf.d/date_timezone.ini && echo "memory_limit=1G" >> /etc/php/7.2/apache2/php.ini


# Install deps + add Chrome Stable + purge all the things
RUN apt-get update && apt-get install -y gnupg --no-install-recommends \
  && curl -sSL https://deb.nodesource.com/setup_12.x | bash - \
  && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update && apt-get install -y \
  google-chrome-stable \
  fontconfig \
  fonts-ipafont-gothic \
  fonts-wqy-zenhei \
  fonts-thai-tlwg \
  fonts-kacst \
  fonts-symbola \
  fonts-noto \
  fonts-freefont-ttf \
  nodejs \
  --no-install-recommends \
  && apt-get purge --auto-remove -y curl gnupg \
  && rm -rf /var/lib/apt/lists/*

ARG CACHEBUST=1
RUN npm install -g lighthouse

# Add Chrome as a user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
  && mkdir -p /home/chrome/reports && chown -R chrome:chrome /home/chrome

# some place we can mount and view lighthouse reports
VOLUME /home/chrome/reports
WORKDIR /home/chrome/reports

# Run Chrome non-privileged
USER chrome

# Drop to cli
CMD ["/bin/bash"]
