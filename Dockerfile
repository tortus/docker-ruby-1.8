FROM debian:8
LABEL ruby="1.8.7-p375"
WORKDIR /root
USER root

ENV RUBY_VERSION="1.8.7-p375"
ARG RUBY_BUILD_VERSION="20180601"
ARG RUBY_BUILD_URL="https://github.com/rbenv/ruby-build/archive/v${RUBY_BUILD_VERSION}.tar.gz"
ARG BUNDLER_VERSION="1.17.3"

# Include tini since there is no reason not to. Just makes the image safer.
ARG TINI_VERSION="v0.18.0"
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# 1. Change sources so packages can be installed now that Debian 8 is EOL.
# 2. Install Ruby 1.8 build dependencies.
# 3. Build Ruby 1.8.
# 4. Install gems:
#     * Rake 0.7.3 is needed to install slimgems and older Rails sites.
#     * Slimgems is needed for Rails 1 and 2 to install, and for other old gems.
#     * Include the last bundler to work with Ruby 1.8.
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list && \
  sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list && \
  apt-get -o Acquire::Check-Valid-Until=false update && \
  apt-get install -y --no-install-recommends \
    autoconf \
    bison \
    build-essential \
    ca-certificates \
    libreadline6 \
    libreadline-dev \
    libssl1.0.0 \
    libssl-dev \
    openssl \
    subversion \
    wget && \
  wget -O ruby-build.tar.gz ${RUBY_BUILD_URL} && \
  tar -xf ruby-build.tar.gz && \
  cd ruby-build-${RUBY_BUILD_VERSION} && ./install.sh && \
  cd .. && rm ruby-build.tar.gz && rm -rf ruby-build-${RUBY_BUILD_VERSION} && \
  mkdir -p /opt/rubies && \
  /usr/local/bin/ruby-build -v ${RUBY_VERSION} /opt/rubies/${RUBY_VERSION} && \
  /opt/rubies/${RUBY_VERSION}/bin/gem install rake -v 0.7.3 --no-ri --no-rdoc && \
  /opt/rubies/${RUBY_VERSION}/bin/gem install slimgems --no-ri --no-rdoc && \
  /opt/rubies/${RUBY_VERSION}/bin/gem install bundler -v ${BUNDLER_VERSION} --no-ri --no-rdoc && \
  apt-get purge -y --auto-remove \
    autoconf \
    bison \
    build-essential \
    libreadline-dev \
    libssl-dev \
    subversion \
    wget && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH="/opt/rubies/${RUBY_VERSION}/bin:${PATH}"

CMD ["/opt/rubies/${RUBY_VERSION}/bin/irb"]
