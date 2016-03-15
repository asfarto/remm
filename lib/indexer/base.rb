module Indexer
  class Base
    include Sidekiq::Worker
    sidekiq_options queue: 'elasticsearch', retry: false

    Client = Elasticsearch::Client.new log: true, url: ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200/'

    def perform(record_id, operation)
      Sidekiq.logger.debug [operation, "ID: #{record_id}"]

      case operation.to_s
        when /index/
          do_index(record_id)
        when /delete/
          do_delete(record_id)
        else raise ArgumentError, "Unknown operation '#{operation}'"
      end
    end

    private

    def do_index(record_id)
      resources = get_resources(record_id)
      resources.each do | resource, records |
        records.each do | rec |
          if defined? rec.as_indexed_json
            body = rec.as_indexed_json
          else
            body = rec.as_json
          end
          Client.index index: resource.index_name, type: resource.document_type, id: rec.id, body: body
        end
      end
    end

    def do_delete(record_id)
      resources = get_resources(record_id)
      resources.each do | resource, records |
        records.each do | rec |
          Client.delete index: resource.index_name, type: resource.to_s.downcase, id: rec.id
        end
      end
    end
  end
end