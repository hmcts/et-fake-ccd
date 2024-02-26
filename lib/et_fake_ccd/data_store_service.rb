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

    def self.update_case_data(json, jid:, ctid:, cid:)
      instance.update_case_data(json, jid: jid, ctid: ctid, cid: cid)
    end

    def store_case_data(json, jid:, ctid:)
      adapter.store(json, jid: jid, ctid: ctid)
    end

    def update_case_data(json, jid:, ctid:, cid:)
      adapter.update_case_data(json, jid: jid, ctid: ctid, cid: cid)
    end

    def find_case_data_by_id(id, jid:, ctid:)
      adapter.fetch_by_id(id.to_s, jid: jid, ctid: ctid)
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
        errors = validate(json, jid: jid, ctid: ctid)
        throw :invalid, errors unless errors.empty?

        self.id = id + 1
        if ctid =~ /Multiples/
          primary_case_ref = json.dig('data', 'caseIdCollection').first.dig('value', 'ethos_CaseReference')
          json['data']['multipleReference'] = next_case_reference(primary_case_ref[0,2]) if primary_case_ref && (json.dig('data', 'multipleReference').nil? || json.dig('data', 'multipleReference') == '')
        else
          json['data']['ethosCaseReference'] = next_case_reference(json.dig('data', 'feeGroupReference')[0,2].to_i) if json.dig('data', 'ethosCaseReference').nil? || json.dig('data', 'ethosCaseReference') == ''
        end
        data[jid] ||= {}
        data[jid][ctid] ||= {}
        data[jid][ctid][id.to_s] = json
        id.to_s
      end

      def fetch_by_id(id, jid:, ctid:)
        data.dig(jid, ctid, id.to_s)
      end

      def fetch_by_fee_group_reference(reference, jid:, ctid:)
        cases = data.dig(jid, ctid)
        return nil if cases.nil? || cases.empty?

        cases.find { |_, case_data| case_data.dig('data', 'feeGroupReference') == reference}&.last
      end

      def fetch_all(jid:, ctid:, filters: {}, page: 1, sort_direction: 'asc', page_size: 25)
        hash = data.dig(jid, ctid)
        return {} if hash.nil? || hash.empty?

        filtered_list = filter(hash, filters: filters)
        sorted_list = sort(filtered_list, sort_direction: sort_direction)
        paginate(sorted_list, page_size: page_size, page: page)
      end

      def update_case_data(json, jid:, ctid:, cid:)
        existing = fetch_by_id(cid.to_s, jid: jid, ctid: ctid)
        existing['data'].merge!(json['data'])
      end

      private

      attr_accessor :data, :id

      def sequence_for_office(office_code)
        @sequences ||= {}
        @sequences[office_code] ||= 0
        @sequences[office_code] += 1
      end

      def next_case_reference(office)
        "#{office}#{sequence_for_office(office).to_s.rjust(5, '0')}/#{Time.now.year}"
      end

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

      def validate(json, jid:, ctid:)
        fee_group_reference = json.dig('data', 'feeGroupReference')
        return [] if fee_group_reference.nil? || fee_group_reference.empty?

        return [{ field: 'data.feeGroupReference', error: :duplicate }] if fetch_by_fee_group_reference(fee_group_reference, jid: jid, ctid: ctid)

        []
      end
    end
  end
end
