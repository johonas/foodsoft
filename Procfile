web: bundle exec rake assets:precompile && bundle exec rails server --binding=0.0.0.0 --port=$PORT
worker: bundle exec rails r bin/start_redis_worker.rb
mail: bundle exec rake foodsoft:reply_email_smtp_server
cron: supercronic crontab
