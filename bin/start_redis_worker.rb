Resque.workers.each {|w| w.unregister_worker}
exec("RAILS_ENV=production QUEUE=#{FoodsoftConfig[:redis_queue]} COUNT=5 PIDFILE=./resque.pid BACKGROUND=yes bundle exec rake resque:workers")
