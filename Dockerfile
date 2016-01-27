FROM ubuntu:14.04.3

MAINTAINER Daniel STANCU <birkof@birkof.ro>

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV TIMEZONE "Europe/Bucharest"

# A few minor docker-specific tweaks (see https://github.com/docker/docker/blob/master/contrib/mkimage/debootstrap)
RUN echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
    && echo 'exit 101' >> /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    \
    && dpkg-divert --local --rename --add /sbin/initctl \
    && cp -a /usr/sbin/policy-rc.d /sbin/initctl \
    && sed -i 's/^exit.*/exit 0/' /sbin/initctl \
    \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
    \
    && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
    && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
    && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
    \
    && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
    \
    && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes

# Enable Ubuntu Universe and Multiverse.
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list \
    && sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list

# Update repos 
RUN apt-get update
    
## Install HTTPS support for APT
RUN apt-get install -yq --no-install-recommends apt-transport-https ca-certificates

## Install add-apt-repository
RUN apt-get install -yq --no-install-recommends software-properties-common

# Upgrade all packages
RUN apt-get dist-upgrade -y --no-install-recommends

# Fix locale
RUN apt-get install -yq --no-install-recommends language-pack-en \
    && locale-gen en_US \
    && update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Often used tools
RUN apt-get install -yq --no-install-recommends \
    mc \
    less \
    vim \
    wget \
    curl \
    git-core \
    openssh-client \
    bash-completion

# Injecting container assets files
ADD assets /

# Supervisor installation && set nodaemon to true
RUN apt-get install -yq --no-install-recommends supervisor \
    && sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

# Bash git completion
RUN curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh \
    && echo 'source ~/.git-prompt.sh' >> ~/.bashrc

# Force color bash prompt
RUN sed -i "s/#force_color_prompt=yes/force_color_prompt=yes/" ~/.bashrc

# Configure system timezone
RUN echo $TIMEZONE > /etc/timezone; dpkg-reconfigure tzdata

# hstr repo
RUN export LANG=C.UTF-8 \
    && add-apt-repository ppa:ultradvorka/ppa

# Update & install hh
RUN apt-get update \
    && apt-get install -yq --no-install-recommends hh
    
# Install latest Node.js package
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash - \
    && apt-get install -yq --no-install-recommends nodejs

# Clean up the mess
RUN apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Sets the working directory for entrypoint file
WORKDIR /sbin

# Default entrypoint
ENTRYPOINT ["bootstrap.sh"]
