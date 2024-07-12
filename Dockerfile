FROM rubylang/ruby:2.3.8-bionic

ENV PORT=3000 \
    SMTP_SERVER_PORT=2525 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_PATH=/home/app/bundle \
    BUNDLE_APP_CONFIG=/home/app/bundle/config

WORKDIR /home/app/src

COPY . ./

## install dependencies and generate crontab
RUN buildDeps='libmagic-dev shared-mime-info build-essential g++ sqlite3 libsqlite3-dev default-libmysqlclient-dev ruby-dev' && \
    apt-get update && \
    apt-get install --no-install-recommends -y $buildDeps

RUN bundle install --without development test -j 4
#    apt-get purge -y --auto-remove $buildDeps && \
#    rm -Rf /var/lib/apt/lists/* /var/cache/apt/* ~/.gemrc ~/.bundle

# compile assets with temporary mysql server
RUN export SECRET_KEY_BASE=thisisnotimportantnow && \
    bundle exec rake assets:precompile


## Make relevant dirs writable for app user
#RUN mkdir -p tmp && \
#    chown nobody tmp

## Run app as unprivileged user
#USER nobody

EXPOSE 3000

## cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
CMD ["./proc-start", "worker"]
