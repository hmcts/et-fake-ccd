require 'active_model'
module EtFakeCcd
  module Command
    class CreateCaseCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      SCHEMA_FILE = File.absolute_path(File.join('..', 'case_create.json'), __dir__)

      attribute :data

      def self.from_json(json)
        new data: json
      end

      validate :validate_data

      private

      def validate_data
        validate_claimant_type
        validate_primary_claimant
      end

      def validate_claimant_type
        data.dig('data', 'claimant_TypeOfClaimant').tap do |claimant_type|
          errors.add :data, "Case data validation failed", field_error: { "id": "claimant_TypeOfClaimant", "message": "Wrong is not a valid value" } unless ['Individual', 'Company'].include?(claimant_type)
        end
      end
      def validate_primary_claimant
        data.dig('data', 'claimantType', 'claimant_phone_number').tap do |phone|
          errors.add :data, "Case data validation failed", field_error: { id: "claimantType.claimant_phone_number", message: "The data entered is not valid for this type of field, please delete and re-enter using only valid data" } if phone.present? && phone.length > 14
        end
        data.dig('data', 'claimantType', 'claimant_mobile_number').tap do |phone|
          errors.add :data, "Case data validation failed", field_error: { id: "claimantType.claimant_mobile_number", message: "The data entered is not valid for this type of field, please delete and re-enter using only valid data" } if phone.present? && phone.length > 14
        end
        data.dig('data', 'claimantIndType', 'claimant_gender').tap do |gender|
          next if gender.nil?
          valid_values = ['Male', 'Female', 'Not Known', 'Non-binary']
          errors.add :data, "Case data validation failed", field_error: { id: 'claimantIndType.claimant_gender', message: "#{gender} is not a valid value" } unless valid_values.include?(gender)
        end
        data.dig('data', 'claimantIndType', 'claimant_title1').tap do |title|
          next if title.nil?
          valid_values = ['Mr', 'Mrs', 'Miss', 'Ms', 'Dr', 'Prof', 'Sir', 'Lord', 'Lady', 'Dame', 'Capt', 'Rev', 'Other']
          errors.add :data, "Case data validation failed", field_error: { id: 'claimantIndType.claimant_title1', message: "#{title} is not a valid value" } unless valid_values.include?(title)
        end
        data.dig('data', 'claimantType', 'claimant_contact_preference').tap do |pref|
          next if pref.nil?
          valid_values = ['Email', 'Post']
          errors.add :data, "Case data validation failed", field_error: { id: 'claimantType.claimant_contact_preference', message: "#{pref} is not a valid value" } unless valid_values.include?(pref)
        end
      end
    end
  end
end

#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T15:33:41.417","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T15:51:15.291","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimantType.claimant_mobile_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"},{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T16:02:28.045","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimant_TypeOfClaimant","message":"Wrong is not a valid value"},{"id":"claimantType.claimant_mobile_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"},{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
