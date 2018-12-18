Resque.workers.each {|w| w.unregister_worker}
exec("RAILS_ENV=production QUEUE=#{FoodsoftConfig[:redis_queue]} PIDFILE=./resque.pid BACKGROUND=yes bundle exec rake resque:work")
