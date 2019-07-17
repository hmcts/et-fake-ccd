require 'active_model'
module EtFakeCcd
  module Command
    class CreateBulkActionCaseCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :data

      def self.from_json(json)
        new data: json
      end
    end
  end
end
