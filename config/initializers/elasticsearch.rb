class ElasticsearchClient
  class << self
    def connection
      connection_to_local hosts('cbank_entry')
    end

    private

    def hosts(cbank_entry_or_group_message)
      [{ host: '127.0.0.1', port: 9200 }]
    end

    def connection_to_local(hosts)
      Elasticsearch::Client.new(
        hosts: hosts,
        randomize_hosts: true,
        request_timeout: 10,
        reload_connections: 500,
        sniffer_timeout: 3,
        reload_on_failure: false,
        log: false
      )
    end
  end
end
