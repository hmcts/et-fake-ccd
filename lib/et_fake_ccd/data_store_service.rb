require "singleton"
module EtFakeCcd
  class DataStoreService
    include Singleton
    def self.store_case_data(json, jid:, ctid:)
      instance.store_case_data(json, jid: jid, ctid: ctid)
    end

    def self.find_case_data_by_id(id, jid:, ctid:)
      instance.find_case_data_by_id(id, jid: jid, ctid: ctid)
    end

    def self.list(jid:, ctid:, filters: {}, page: 1, sort_direction: 'asc', page_size: 25)
      instance.list(jid: jid, ctid: ctid, filters: filters, page: page, sort_direction: sort_direction, page_size: page_size)
    end

    def store_case_data(json, jid:, ctid:)
      adapter.store(json, jid: jid, ctid: ctid)
    end

    def find_case_data_by_id(id, jid:, ctid:)
      adapter.fetch_by_id(id, jid: jid, ctid: ctid)
    end

    def list(jid:, ctid:, filters: {}, page: 1, sort_direction: 'asc', page_size: 25)
      adapter.fetch_all(jid: jid, ctid: ctid, filters: filters, page: page, sort_direction: sort_direction, page_size: page_size)
    end

    def adapter
      @adapter ||= InMemoryAdapter.new
    end

    class InMemoryAdapter
      def initialize
        self.data = {}
        self.id = 10000000000
      end

      def store(json, jid:, ctid:)
        self.id = id + 1
        data[jid] ||= {}
        data[jid][ctid] ||= {}
        data[jid][ctid][id] = json
        id
      end

      def fetch_by_id(id, jid:, ctid:)
        data.dig(jid, ctid, id)
      end

      def fetch_all(jid:, ctid:, filters: {}, page: 1, sort_direction: 'asc', page_size: 25)
        hash = data.dig(jid, ctid)
        return [] if hash.nil? || hash.empty?

        filtered_list = filter(hash, filters: filters)
        sorted_list = sort(filtered_list, sort_direction: sort_direction)
        paginate(sorted_list, page_size: page_size, page: page)
      end

      private

      attr_accessor :data, :id

      def filter(list, filters:)
        return list if filters.nil? || filters.empty?

        list.select do |id, item|
          included?(item, filters: filters)
        end
      end

      def sort(list, sort_direction:)
        return list if sort_direction == 'asc'

        list.sort {|l, r| r <=> l}
      end

      def included?(item, filters:)
        filters.all? do |(key, value)|
          get_attribute_by_json_path(item, key) == value
        end
      end

      def get_attribute_by_json_path(item, key)
        path = key.split('.')
        path[0] = 'data' if path[0] == 'case'
        item.dig(*path)
      end

      def paginate(list, page_size:, page:)
        arr = list.to_a[page_size * (page - 1) .. (page_size * page) - 1]
        arr.to_h
      end

    end
  end
end
