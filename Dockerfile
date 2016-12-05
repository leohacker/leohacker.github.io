FROM ubuntu:16.04
MAINTAINER Leo Jiang "leo.jiang.dev@gmail.com"
RUN  apt-get -y update && \
     apt-get --no-install-recommends install -q -y curl ruby ruby-dev gcc make zlib1g-dev nodejs && \
     rm -rf /var/lib/apt/lists/*
RUN  gem install bundle && \
     bundle config mirror.https://rubygems.org https://gems.ruby-china.org
COPY Gemfile /root
RUN  cd /root && bundle install

VOLUME /root/hackerblog
EXPOSE 400

ENTRYPOINT ["jekyll", "server", \
            "--config", "/root/hackerblog/_config.yml", \
            "-s", "/root/hackerblog", "-d", "/root/hackerblog/_site", \
            "--host", "0.0.0.0"]
CMD ["-w", "-q"]
