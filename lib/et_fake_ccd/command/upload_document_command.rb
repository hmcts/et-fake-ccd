require 'active_model'
module EtFakeCcd
  module Command
    class UploadDocumentCommand
      include ActiveModel::Model
      include ActiveModel::Attributes
      VALID_FILE_EXTENSIONS = ['.pdf', '.csv', '.rtf'].freeze
      VALID_FILE_CONTENT_TYPES = ['application/pdf', 'text/csv', 'application/rtf'].freeze

      attribute :data

      def self.from_json(json)
        new data: json
      end

      validate :validate_data

      private

      def validate_data
        validate_file
      end

      def validate_file
        return if validate_file_extension && validate_file_content_type

        errors.add :data, "Your upload contains a disallowed file type", field_error: { "id": "files", "message": "Your upload contains a disallowed file type" }
      end

      def validate_file_content_type
        VALID_FILE_CONTENT_TYPES.include?(data.dig('files', 'type'))
      end

      def validate_file_extension
        VALID_FILE_EXTENSIONS.include?(File.extname(data.dig('files', 'filename')))
      end
    end
  end
end
