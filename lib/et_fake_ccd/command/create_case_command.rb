require 'active_model'
require 'json-schema'
module EtFakeCcd
  module Command
    class CreateCaseCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      SCHEMA_FILE = File.absolute_path(File.join('..', 'case_create.json'), __dir__)
      ELMOS_BIRTHDAY = Time.new(2019,9,1).to_f

      attribute :data

      def self.from_json(json)
        new data: json.dup
      end

      validate :validate_json_schema

      private

      def validate_json_schema
        return if EtFakeCcd.config.create_case_schema_file.nil?

        schema_errors = JSON::Validator.fully_validate(EtFakeCcd.config.create_case_schema_file, data['data'])
        return if schema_errors.empty?

        schema_errors.each do |error|
          errors.add :data, 'Case data validation failed (json schema)', field_error: { id: 'none', message: error }
        end
      end
    end
  end
end

#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T15:33:41.417","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T15:51:15.291","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimantType.claimant_mobile_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"},{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T16:02:28.045","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimant_TypeOfClaimant","message":"Wrong is not a valid value"},{"id":"claimantType.claimant_mobile_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"},{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
