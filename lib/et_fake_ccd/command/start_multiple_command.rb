require 'active_model'
module EtFakeCcd
  module Command
    class StartMultipleCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      # @!attribute case_ref_number_count
      #  @return [Integer] The number of case references to generate
      attribute :case_ref_number_count

      # @!attribute case_type_id
      #  @return [String] The ccd case type id (e.g. Manchester, Glasgow)
      attribute :case_type_id

      def self.from_json(json)
        case_ref_number_count = json.dig('case_details', 'case_data', 'caseRefNumberCount')
        case_type_id = json.dig('case_details', 'case_type_id')
        new case_ref_number_count: case_ref_number_count, case_type_id: case_type_id
      end
    end
  end
end
