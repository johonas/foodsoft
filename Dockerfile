FROM rubylang/ruby:2.3.8-bionic

ENV PORT=3000
ENV SMTP_SERVER_PORT=2525
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV BUNDLE_PATH=/home/app/bundle
ENV BUNDLE_APP_CONFIG=/home/app/bundle/config

WORKDIR /home/app/src

COPY . ./

## install dependencies and generate crontab
RUN buildDeps='libmagic-dev shared-mime-info build-essential g++ sqlite3 libsqlite3-dev default-libmysqlclient-dev ruby-dev' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps

RUN bundle install # --without development test -j 4

EXPOSE 3000

## cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
#CMD ["./proc-start", "web"]
