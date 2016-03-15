namespace :check do
  desc 'Check and start Mysql, Redis and Elasticsearch'
  task :environment do
    if RUBY_PLATFORM == 'x86_64-darwin14'
      puts 'This rake task will check if all dependencies are running, if not it will try to run. '

      if `pgrep mysql` == ''
        print 'Starting Mysql ...'
        `mysql.server start &`
        puts `pgrep mysql`.blank? ? ' [ KO ]' : ' [ OK ]'
      end

      if `ps aux | grep '[e]lasticsearch'` == ''
        print 'Starting Elasticsearch ...'
        `elasticsearch -d --path.conf=#{Rails.root}/config`
        puts `ps aux | grep '[e]lasticsearch'`.blank? ? ' [ KO ]' : ' [ OK ]'
      end

      if `pgrep redis` == ''
        print 'Starting Redis ...'
        `/usr/local/Cellar/redis/3.0.5/bin/redis-server /usr/local/etc/redis.conf &`
        puts `pgrep redis`.blank? ? ' [ KO ]' : ' [ OK ]'
      end

      if `pgrep sidekiq` == ''
        print 'Starting Sidekiq ...'
        `bundle exec sidekiq -d`
        puts `pgrep sidekiq`.blank? ? ' [ KO ]' : ' [ OK ]'
      end
    end
  end
end
