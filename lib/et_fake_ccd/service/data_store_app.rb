require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/data_store_service'
module EtFakeCcd
  module Service
    class DataStoreApp < Roda
      plugin :request_headers
      plugin :halt
      route do |r|
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "event-triggers", "initiateCase", "token" do |uid, jid, ctid|
          r.get do
            if EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) && EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
              initiate_case(uid, jid, ctid)
            else
              r.halt 403, forbidden_error_for(r)
            end
          end
        end
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "cases" do |uid, jid, ctid|
          r.post do
            if !EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) || !EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
              r.halt 403, forbidden_error_for(r)
              break
            end
            json = JSON.parse(r.body.read)
            command = ::EtFakeCcd::Command::CreateCaseCommand.from_json json
            if command.valid?
              id = ::EtFakeCcd::DataStoreService.store_case_data(json, jid: jid, ctid: ctid)
              case_created_response(id, uid, jid, ctid)
            else
              r.halt 422, render_error_for(command, r)
            end
          end

          r.get do
            if !EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) || !EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
              r.halt 403, forbidden_error_for(r)
              break
            end
            filters = r.params.dup
            page = (filters.delete('page') || "1").to_i
            sort_direction = filters.delete('sortDirection') || 'asc'
            list = DataStoreService.list(jid: jid, ctid: ctid, filters: filters, page: page, sort_direction: sort_direction, page_size: 25)
            cases_response(list, uid, jid, ctid)
          end
        end
      end

      private

      def initiate_case(uid, jid, ctid)
        j = {
            "token": "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJvZDRwZ3NhbDQwcTdndHI0Y2F1bmVmZGU5aSIsInN1YiI6IjIyIiwiaWF0IjoxNTYxOTY2NzM1LCJldmVudC1pZCI6ImluaXRpYXRlQ2FzZSIsImNhc2UtdHlwZS1pZCI6IkVtcFRyaWJfTVZQXzEuMF9NYW5jIiwianVyaXNkaWN0aW9uLWlkIjoiRU1QTE9ZTUVOVCIsImNhc2UtdmVyc2lvbiI6ImJmMjFhOWU4ZmJjNWEzODQ2ZmIwNWI0ZmEwODU5ZTA5MTdiMjIwMmYifQ.u-OfexKFu52uvSgTNVHJ5kUQ9KTZGClRIRnGXRPSmGY",
            "case_details": {
                "id": nil,
                "jurisdiction": jid,
                "state": nil,
                "case_type_id": ctid,
                "created_date": nil,
                "last_modified": nil,
                "security_classification": nil,
                "case_data": {},
                "data_classification": {},
                "after_submit_callback_response": nil,
                "callback_response_status_code": nil,
                "callback_response_status": nil,
                "delete_draft_response_status_code": nil,
                "delete_draft_response_status": nil,
                "security_classifications": {}
            },
            "event_id": "initiateCase"
        }
        JSON.generate(j)
      end

      def case_created_response(id, uid, jid, ctid)
        j = case_hash(ctid, id, jid)
        JSON.generate(j)
      end

      def case_hash(ctid, id, jid)
        {
            "id": id,
            "jurisdiction": jid,
            "state": "1_Submitted",
            "case_type_id": ctid,
            "created_date": "2019-07-01T09:37:37.936",
            "last_modified": "2019-07-01T09:37:37.936",
            "security_classification": "PUBLIC",
            "case_data": ::EtFakeCcd::DataStoreService.find_case_data_by_id(id, jid: jid, ctid: ctid)['data'],
            "data_classification": {},
            "after_submit_callback_response": nil,
            "callback_response_status_code": nil,
            "callback_response_status": nil,
            "delete_draft_response_status_code": nil,
            "delete_draft_response_status": nil,
            "security_classifications": {}
        }
      end

      def cases_response(list, uid, jid, ctid)
        j = list.keys.map do |id|
          case_hash(ctid, id, jid)
        end
        JSON.generate(j)
      end

      def forbidden_error_for(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":403,"error":"Forbidden","message":"Access Denied","path": r.path}
        JSON.generate(j)
      end

      def render_error_for(command, request)
        j = {
            "exception": "uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException",
            "timestamp": "2019-07-01T16:02:28.045",
            "status": 422,
            "error": "Unprocessable Entity",
            "message": "Case data validation failed",
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
