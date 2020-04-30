require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/ecm_service'
module EtFakeCcd
  module Service
    class EcmApp < Roda
      plugin :request_headers
      plugin :halt
      route do |r|
        r.is "generateCaseRefNumbers" do
          r.post do
            unless EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) && EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
              r.halt 403, forbidden_error_for(r)
              break
            end
            json = JSON.parse(r.body.read)
            command = ::EtFakeCcd::Command::StartMultipleCommand.from_json json
            if command.valid?
              response = ::EtFakeCcd::EcmService.start_multiple(command)
              start_multiple_response(response)
            else
              r.halt 422, render_error_for(command, r)
            end
          end
        end
      end

      private

      def render_error403(r)
        r.halt 403, forbidden_error_for(r)
      end

      def start_multiple_response(response)
        j = {
          "data": {
            "caseRefNumberCount": response.case_reference_count,
            "startCaseRefNumber": response.start_reference,
            "multipleRefNumber": response.multiple_reference
          }
        }
        JSON.generate(j)
      end

      def render_error_for(command, request)
        j = {
            "exception": "uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException",
            "timestamp": "2019-07-01T16:02:28.045",
            "status": 422,
            "error": "Unprocessable Entity",
            "message": "Start multiple command validation failed",
            "path": request.path,
            "details": {
                "field_errors": command.errors.details[:data].map {|e| e[:field_error]}
            },
            "callbackErrors": nil,
            "callbackWarnings": nil
        }

        JSON.generate(j)
      end
    end
  end
end
