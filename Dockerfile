FROM ruby:2.3.8

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list

ENV PORT=3000
ENV SMTP_SERVER_PORT=2525
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV BUNDLE_PATH=/home/app/bundle
ENV BUNDLE_APP_CONFIG=/home/app/bundle/config

WORKDIR /home/app/src

COPY . ./

# install dependencies and generate crontab
RUN apt-get update
RUN apt-get install --no-install-recommends -y 'libmagic-dev'


RUN bundle install --without development test

EXPOSE 3000

# cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
#CMD ["./proc-start", "web"]
