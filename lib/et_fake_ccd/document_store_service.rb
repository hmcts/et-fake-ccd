require "singleton"
require "securerandom"
module EtFakeCcd
  class DocumentStoreService
    include Singleton
    def self.store_file(filename:, type:, file:, classification:)
      instance.store_file(filename: filename, type: type, file: file, classification: classification)
    end

    def self.find_by_id(id)
      instance.find_by_id(id)
    end

    def self.find_file_by_id(id)
      instance.find_file_by_id(id)
    end

    def store_file(filename:, type:, file:, classification:)
      adapter.store(filename: filename, type: type, file: file, classification: classification)
    end

    def find_by_id(id)
      adapter.fetch_by_id(id)
    end

    def find_file_by_id(id)
      adapter.fetch_file_by_id(id)
    end

    def adapter
      @adapter ||= InMemoryAdapter.new
    end

    class InMemoryAdapter
      def initialize(file_storage_path: ::EtFakeCcd.config.file_storage_path)
        self.data = {}
        self.file_storage_path = file_storage_path
      end

      def store(filename:, type:, file:, classification:)
        uuid = SecureRandom.uuid
        file_path = File.join(file_storage_path, uuid)
        FileUtils.cp file.path, file_path
        data[uuid] = {
          'filename' => filename,
          'type' => type,
          'file_path' => uuid,
          'size' => file.size,
          'classification' => classification
        }
        uuid
      end

      def fetch_by_id(id)
        data[id]
      end

      def fetch_file_by_id(id)
        document = fetch_by_id(id)
        return nil if document.nil?

        File.new(File.join(file_storage_path, document['file_path']), 'rb')
      end

      private

      attr_accessor :data, :file_storage_path
    end
  end
end
