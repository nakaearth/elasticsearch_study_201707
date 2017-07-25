class User < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :books

  index_name = 'es_user'

  settings index: {
      number_of_shards:   5,
      number_of_replicas: 1,
      analysis: {
        filter: {
          pos_filter: {
            type:     'kuromoji_part_of_speech',
            stoptags: ['助詞-格助詞-一般', '助詞-終助詞']
          },
          greek_lowercase_filter: {
            type:     'lowercase',
            language: 'greek'
          },
          kuromoji_ks: {
            type: 'kuromoji_stemmer',
            minimum_length: '5'
          }
        },
        tokenizer: {
          kuromoji: {
            type: 'kuromoji_tokenizer'
          },
          ngram_tokenizer: {
            type: 'nGram',
            min_gram: '2',
            max_gram: '3',
            token_chars: %w(letter digit)
          }
        },
        analyzer: {
          kuromoji_analyzer: {
            type:      'custom',
            tokenizer: 'kuromoji_tokenizer',
            filter:    %w(kuromoji_baseform pos_filter greek_lowercase_filter cjk_width)
          },
          ngram_analyzer: {
            tokenizer: 'ngram_tokenizer'
          }
        }
      }
    } do
      mapping _source: { enabled: true },
              _all: { enabled: true, analyzer: 'kuromoji_analyzer' } do
        indexes :id,            type: 'integer', index: 'not_analyzed'
        indexes :name,          type: 'text', analyzer: 'kuromoji_analyzer'
        indexes :age,           type: 'long', index: 'not_analyzed'
        indexes :profile,       type: 'text', analyzer: 'kuromoji_analyzer'
        indexes :gender,        type: 'long', index: 'not_analyzed'
        indexes :books,         type: 'nested' do
          indexes :title,       type: 'text', analyzer: 'kuromoji_analyzer'
          indexes :description, type: 'text', analyzer: 'kuromoji_analyzer'
        end
        indexes :created_at,    type: 'date', format: 'date_time'
        indexes :updated_at,    type: 'date', format: 'date_time'
      end
    end

    def as_indexed_json(options = {})
      as_json.merge(as_indexed_json_book(options))
    end

    class << self
      def create_index!(options = {})
        client = __elasticsearch__.client
        client.indices.delete index: index_name if options[:force]
        client.indices.create index: index_name,
                              body: {
                                settings: settings.to_hash,
                                mappings: mappings.to_hash
                              }

      end

      def bulk_import
        es = __elasticsearch__

        find_in_batches.with_index do |entries, _i|
          result = es.client.bulk(
            index: es.index_name,
            type: es.document_type,
            body: entries.map { |entry| { index: { _id: entry.id, data: entry.as_indexed_json } } },
            refresh: true, # NOTE: 定期的にrefreshしないとEsが重くなる
          )

          Rails.logger.debug("[#{i}] took:#{result['took']} erros:#{result['errors']} items:#{result['items'].size}")
        end
      end
    end

    private

  def as_indexed_json_book(options = {})
    return {} unless books

    { books: books.map{ |book| book.attributes } }
  end
end
