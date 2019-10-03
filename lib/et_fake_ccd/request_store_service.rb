require "singleton"
module EtFakeCcd
  class RequestStoreService
    include Singleton
    def self.store(request_id)
      instance.store(request_id)
    end

    def self.count(request_id)
      instance.count(request_id)
    end

    def store(request_id)
      adapter.store(request_id)
    end

    def count(request_id)
      adapter.count(request_id)
    end

    def adapter
      @adapter ||= InMemoryAdapter.new
    end

    class InMemoryAdapter
      TTL = 1800
      def initialize
        self.data = {}
      end

      def store(request_id)
        expire_old_requests(request_id)
        data[request_id] ||= []
        data[request_id] << Time.now.utc
      end

      def count(request_id)
        expire_old_requests(request_id)
        return 0 if data[request_id].nil?

        data[request_id].length
      end

      private

      attr_accessor :data

      def expire_old_requests(request_id)
        return unless data.key?(request_id) && data[request_id].length > 0

        last_request = data[request_id].max
        if (Time.now - last_request) > TTL
          data[request_id].clear
        end
      end
    end
  end
end
