class TestSearch
  def initialize(params)
    @params = params
  end

  def search
    Elasticsearch::Model.client = ElasticsearchClient.connection
    client = User.__elasticsearch__

    Rails.logger.info query
    client.index_name = 'users'
    client.search(query).records
  end

  private

    def query
      query_hash = {
        query: {
          bool: {
            must: {
              simple_query_string: {
                query: "\"#{@params[:keyword]}\"",
                fields: ['name'],
                default_operator: 'and',
              }
            },
            # should: {},
            # not: {},
          }
        },
        from: @params[:page]  || 0,
        size: @params[:limit] || 20,
        sort: [{ created_at: { order: 'DESC' } }]
      }

      query_hash.to_json
    end
end
