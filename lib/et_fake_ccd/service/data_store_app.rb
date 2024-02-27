require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/forced_error_handling'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/data_store_service'
require 'et_fake_ccd/request_store_service'
module EtFakeCcd
  module Service
    class DataStoreApp < Roda
      include ForcedErrorHandling
      attr_accessor :success_response
      plugin :request_headers
      plugin :halt
      route do |r|
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "event-triggers", "initiateCase", "token" do |uid, jid, ctid|
          r.get do
            with_forced_error_handling(r, stage: :token) do
              if EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) && EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                initiate_case(uid, jid, ctid)
              else
                r.halt 403, forbidden_error_for(r)
              end
            end
          end
        end
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "event-triggers", "createMultiple", "token" do |uid, jid, ctid|
          r.get do
            with_forced_error_handling(r, stage: :token) do
              if EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) && EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                initiate_bulk_case(uid, jid, ctid)
              else
                r.halt 403, forbidden_error_for(r)
              end
            end
          end
        end
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "cases", String, "event-triggers", "uploadDocument", "token" do |uid, jid, ctid, cid|
          r.get do
            with_forced_error_handling(r, stage: :documents) do
              if EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) && EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                initiate_upload_document(uid, jid, ctid, cid)
              else
                r.halt 403, forbidden_error_for(r)
              end
            end
          end
        end
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "cases", String, "events" do |uid, jid, ctid, cid|
          r.post do
            with_forced_error_handling(r, stage: :documents) do
              if !EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) || !EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                r.halt 403, forbidden_error_for(r)
                break
              end
              json = JSON.parse(r.body.read)
              command = case json.dig('event', 'id')
                        when 'uploadDocument' then ::EtFakeCcd::Command::UploadDocumentsToCaseCommand.from_json json
                        else
                          r.halt 400, unknown_event_error_for(r)
                        end
              if command.valid?
                ::EtFakeCcd::DataStoreService.update_case_data(json, jid: jid, ctid: ctid, cid: cid)
                case_updated_response(cid, uid, jid, ctid)
              else
                r.halt 422, render_error_for(command, r)
              end
            end
          end
        end
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "cases", String do |uid, jid, ctid, case_id|
          r.get do
            with_forced_error_handling(r, stage: :data) do
              if !EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) || !EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                r.halt 403, forbidden_error_for(r)
                break
              end
              case_response(case_id, uid, jid, ctid)
            end
          end

        end
        r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "cases" do |uid, jid, ctid|
          r.post do
            with_forced_error_handling(r, stage: :data) do
              if !EtFakeCcd::AuthService.validate_service_token(r.headers['ServiceAuthorization'].gsub(/\ABearer /, '')) || !EtFakeCcd::AuthService.validate_user_token(r.headers['Authorization'].gsub(/\ABearer /, ''))
                r.halt 403, forbidden_error_for(r)
                break
              end
              json = JSON.parse(r.body.read)
              next if force_deliberate_error(json, r)
              next if force_deliberate_sequence(json, r)

              command = case json.dig('event', 'id')
              when 'initiateCase' then ::EtFakeCcd::Command::CreateCaseCommand.from_json json
                        when 'createMultiple' then ::EtFakeCcd::Command::CreateMultipleCaseCommand.from_json json
                        else
                          r.halt 400, unknown_event_error_for(r)
                        end
              if command.valid?
                id = ::EtFakeCcd::DataStoreService.store_case_data(command.data, jid: jid, ctid: ctid)
                if success_response
                  r.halt *success_response
                else
                  case_created_response(id, uid, jid, ctid)
                end
              else
                r.halt 422, render_error_for(command, r)
              end
            end
          end

          r.get do
            with_forced_error_handling(r, stage: :data) do
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
      end

      private

      def force_deliberate_error(data, r)
        return false unless data.dig('data', 'claimantIndType', 'claimant_first_names')&.strip&.downcase == 'force'
        error, client_id = data.dig('data', 'claimantIndType', 'claimant_last_name').split('-')
        if client_id.nil?
          render_error(error, r)
        else
          track_request_id("#{error}-#{client_id}")
          return false unless should_error_for_request_id?("#{error}-#{client_id}")
          render_error(error, r)
        end
        true
      end

      def force_deliberate_sequence(data, r)
        address_line_2 = data.dig('data', 'claimantType', 'claimant_addressUK', 'AddressLine2')&.strip
        return false unless address_line_2&.start_with? 'ForceErrorSequence'

        request_id = JSON.dump(data['data'].reject { |key, _| key == 'documentCollection'} ).hash
        track_request_id(request_id)
        sequences = address_line_2.split(' ')
        sequences.shift

        request_index = RequestStoreService.count(request_id) - 1
        error = sequences[request_index]
        error ||= sequences.last
        error = error.gsub(/([a-z\d])([A-Z])/, '\1_\2').gsub(/([A-Z]+)([A-Z][a-z\d])/, '\1_\2').downcase

        method_name = "sequence_#{error}".to_sym
        return send(method_name, data, r) if respond_to?(method_name, true)

        false
      end

      def sequence_success_with_timeout(data, r)
        self.success_response = [504, JSON.generate({ "message": "Proxy Timeout" })]
        false
      end

      def sequence_conflict(data, r)
        r.halt 409, JSON.generate({ "message": "Conflict" })
        true
      end

      def render_error(error, r)
        method_name = "render_#{error.underscore.downcase}".to_sym
        return unless respond_to?(method_name, true)

        send method_name, r
      end

      def track_request_id(request_id)
        RequestStoreService.store request_id
      end

      def should_error_for_request_id?(request_id)
        RequestStoreService.count(request_id) == 1
      end

      def render_error_forbidden(r)
        r.halt 403, forbidden_error_for(r)
      end

      def render_error_gateway_timeout(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":504,"error":"Forbidden","message":"Access Denied","path": r.path}
        r.halt 504, JSON.generate(j)
      end

      def render_error_bad_gateway(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":502,"error":"Forbidden","message":"Access Denied","path": r.path}
        r.halt 502, JSON.generate(j)
      end

      def render_error_unprocessable_entity(r)
        j = {
          "exception": "uk.gov.hmcts.ccd.endpoint.exceptions.CaseValidationException",
          "timestamp": "2019-07-01T16:02:28.045",
          "status": 422,
          "error": "Unprocessable Entity",
          "message": "Case data validation failed",
          "path": request.path,
          "details": {
            "field_errors": []
          },
          "callbackErrors": nil,
          "callbackWarnings": nil
        }

        r.halt 422, JSON.generate(j)
      end

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

      def initiate_bulk_case(uid, jid, ctid)
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
            "event_id": "createMultiple"
        }
        JSON.generate(j)
      end

      def initiate_upload_document(uid, jid, ctid, cid)
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
            "event_id": "uploadDocument"
        }
        JSON.generate(j)
      end

      def case_created_response(id, uid, jid, ctid)
        j = case_hash(ctid, id, jid)
        JSON.generate(j)
      end

      def case_updated_response(id, uid, jid, ctid)
        j = case_hash(ctid, id, jid)
        JSON.generate(j)
      end

      def case_response(id, uid, jid, ctid)
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

      def unknown_event_error_for(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":400,"error":"Unknown event","message":"Unknown event","path": r.path}
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
