Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200/'

Elasticsearch::Model::Response::Response.__send__ :include, Elasticsearch::Model::Response::Pagination::Kaminari

ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
  next if table == 'schema_migrations'

  if table == 'users'
    if User.__elasticsearch__.index_exists?
      User.__elasticsearch__.refresh_index!
    else
      User.__elasticsearch__.create_index!
      User.import
    end
  end

end



