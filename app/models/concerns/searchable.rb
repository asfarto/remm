module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  end

  def self.included(m)
    def m.fuzzy_search(query, fuzziness=1, size=25)
      self.__elasticsearch__.search(
          query: {
              match: {
                  _all: {
                      query: query,
                      fuzziness: fuzziness
                  }
              }
          },
          size: size
      )
    end

    def m.personalize_search(query)
      self.__elasticsearch__.search(query)
    end

    def m.fuzzy_suggest(query, suggest, fuzziness=1, size=25)
      self.__elasticsearch__.client.suggest(
          index: self.index_name,
          body: {
              suggestions: {
                  text: query,
                  completion: {
                      field: suggest,
                      size: size,
                      fuzzy: {
                          fuzziness: fuzziness
                      }
                  }
              }
          }
      )
    end

    def m.suggest(query, suggest, size=25)
      self.fuzzy_suggest(query, suggest, 0, size)
    end
  end
end
