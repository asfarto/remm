class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include Searchable

  index_name "users-#{Rails.env}"

  settings index: { number_of_shards: 2, number_of_replicas: 2 },
           analysis: {
               analyzer: {
                   default: {
                       type: 'custom',
                       tokenizer: 'standard',
                       filter: %w(standard uppercase lowercase word_delimiter my_ascii_folding english_stemmer spanish_stemmer autocomplete_filter)
                   }
               },
               filter:{
                   my_ascii_folding: {
                       type: 'asciifolding',
                       preserve_original: true
                   },
                   english_stemmer: {
                       type: 'stemmer',
                       name: 'english'
                   },
                   spanish_stemmer: {
                       type: 'stemmer',
                       name: 'light_spanish'
                   },
                   autocomplete_filter: {
                       type:     'edge_ngram',
                       min_gram: 3,
                       max_gram: 20
                   }
               }
           } do
    mappings dynamic: false do
      indexes :first_name,  type: :string
      indexes :last_name,   type: :string
      indexes :username,    type: :completion, payloads: true
      indexes :email,       type: :string
    end
  end

  attr_accessor :login

  private

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(['lower(username) = :value OR lower(email) = :value', {value: login.downcase}]).take
    else
      where(conditions.to_hash).take
    end
  end
end
