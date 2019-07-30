require 'active_model'
module EtFakeCcd
  module Command
    class UploadDocumentCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :data

      def self.from_json(json)
        new data: json
      end

      validate :validate_data

      private

      def validate_data

      end
    end
  end
end

#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T15:33:41.417","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T15:51:15.291","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimantType.claimant_mobile_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"},{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
#{"exception":"uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException","timestamp":"2019-07-01T16:02:28.045","status":422,"error":"Unprocessable Entity","message":"Case data validation failed","path":"/caseworkers/22/jurisdictions/EMPLOYMENT/case-types/EmpTrib_MVP_1.0_Manc/cases","details":{"field_errors":[{"id":"claimant_TypeOfClaimant","message":"Wrong is not a valid value"},{"id":"claimantType.claimant_mobile_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"},{"id":"claimantType.claimant_phone_number","message":"The data entered is not valid for this type of field, please delete and re-enter using only valid data"}]},"callbackErrors":null,"callbackWarnings":null}
