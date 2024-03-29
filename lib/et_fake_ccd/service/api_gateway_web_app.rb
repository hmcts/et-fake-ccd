require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/data_store_service'
module EtFakeCcd
  module Service
    class ApiGatewayWebApp < Roda
      plugin :request_headers
      plugin :halt
      plugin :cookies
      route do |r|
        r.is "oauth2" do
          r.get do
            response.set_cookie('accessToken', 'eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJ1OHM3NXRiOGlmaWhicnVjYWQzcm41bDAwZiIsInN1YiI6IjIyIiwiaWF0IjoxNTYyMDU3OTk5LCJleHAiOjE1NjIwODY3OTksImRhdGEiOiJjYXNld29ya2VyLGNhc2V3b3JrZXItZW1wbG95bWVudC10cmlidW5hbC1tYW5jaGVzdGVyLWNhc2VvZmZpY2VyLGNhc2V3b3JrZXItZW1wbG95bWVudC10cmlidW5hbC1tYW5jaGVzdGVyLWNhc2VzdXBlcnZpc29yLGNhc2V3b3JrZXItZW1wbG95bWVudCxjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtbWFuY2hlc3RlcixjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtZ2xhc2dvdy1jYXNlb2ZmaWNlcixjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtZ2xhc2dvdy1jYXNlc3VwZXJ2aXNvcixjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtZ2xhc2dvdyxjYXNld29ya2VyLGNhc2V3b3JrZXItbG9hMSxjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtbWFuY2hlc3Rlci1jYXNlb2ZmaWNlci1sb2ExLGNhc2V3b3JrZXItZW1wbG95bWVudC10cmlidW5hbC1tYW5jaGVzdGVyLWNhc2VzdXBlcnZpc29yLWxvYTEsY2FzZXdvcmtlci1lbXBsb3ltZW50LWxvYTEsY2FzZXdvcmtlci1lbXBsb3ltZW50LXRyaWJ1bmFsLW1hbmNoZXN0ZXItbG9hMSxjYXNld29ya2VyLWVtcGxveW1lbnQtdHJpYnVuYWwtZ2xhc2dvdy1jYXNlb2ZmaWNlci1sb2ExLGNhc2V3b3JrZXItZW1wbG95bWVudC10cmlidW5hbC1nbGFzZ293LWNhc2VzdXBlcnZpc29yLWxvYTEsY2FzZXdvcmtlci1lbXBsb3ltZW50LXRyaWJ1bmFsLWdsYXNnb3ctbG9hMSxjYXNld29ya2VyLWxvYTEiLCJ0eXBlIjoiQUNDRVNTIiwiaWQiOiIyMiIsImZvcmVuYW1lIjoiQnV6eiIsInN1cm5hbWUiOiJMaWdodHllYXIiLCJkZWZhdWx0LXNlcnZpY2UiOiJDQ0QiLCJsb2EiOjEsImRlZmF1bHQtdXJsIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6OTAwMC9wb2MvY2NkIiwiZ3JvdXAiOiJjYXNld29ya2VyIn0.9Ct8RRBQSjANN8PIvw-mVpfZSOxv8kg68yctRR0JC4M')
            ""
          end
        end
        r.on "aggregated" do
          r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "cases" do |uid, jid, ctid|
            r.get do
              filters = r.params.dup
              page = (filters.delete('page') || "1").to_i
              sort_direction = filters.delete('sortDirection') || 'asc'
              list = DataStoreService.list(jid: jid, ctid: ctid, filters: filters, page: page, sort_direction: sort_direction, page_size: 25)
              cases_response(list, uid, jid, ctid)
            end

            r.post do
              json = JSON.parse(r.body.read)

              command = case json.dig('event', 'id')
              when 'initiateCase' then ::EtFakeCcd::Command::CreateCaseCommand.from_json json
                        when 'createMultiple' then ::EtFakeCcd::Command::CreateMultipleCaseCommand.from_json json
                        else
                          r.halt 400, unknown_event_error_for(r)
                        end
              if command.valid?
                id = ::EtFakeCcd::DataStoreService.store_case_data(command.data, jid: jid, ctid: ctid)
                case_created_response(id, uid, jid, ctid)
              else
                r.halt 422, render_error_for(command, r)
              end

            end
          end
          r.is "caseworkers", String, "jurisdictions", String, "case-types", String, "event-triggers", "initiateCase", "token" do |uid, jid, ctid|
            r.get do
              initiate_case(uid, jid, ctid)
            end
          end
        end
        r.on "data" do
          r.on "internal" do
            r.is "profile" do
              profile_response
            end
          end
        end
      end

      private

      def config
        EtFakeCcd.config
      end

      def cases_response(list, uid, jid, ctid)
        j = {
            results: list.keys.map do |id|
              case_hash(ctid, id, jid)
            end
        }
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
            "case_fields": ::EtFakeCcd::DataStoreService.find_case_data_by_id(id, jid: jid, ctid: ctid)['data'],
            "data_classification": {},
            "after_submit_callback_response": nil,
            "callback_response_status_code": nil,
            "callback_response_status": nil,
            "delete_draft_response_status_code": nil,
            "delete_draft_response_status": nil,
            "security_classifications": {}
        }
      end

      def profile_response
        j = {
            "user": {
                "idam": {
                    "id": "22",
                    "email": "m@m.com",
                    "forename": "Buzz",
                    "surname": "Lightyear",
                    "roles": [
                        "caseworker",
                        "caseworker-employment-tribunal-manchester-caseofficer",
                        "caseworker-employment-tribunal-manchester-casesupervisor",
                        "caseworker-employment",
                        "caseworker-employment-tribunal-manchester",
                        "caseworker-employment-tribunal-glasgow-caseofficer",
                        "caseworker-employment-tribunal-glasgow-casesupervisor",
                        "caseworker-employment-tribunal-glasgow",
                        "caseworker",
                        "caseworker-loa1",
                        "caseworker-employment-tribunal-manchester-caseofficer-loa1",
                        "caseworker-employment-tribunal-manchester-casesupervisor-loa1",
                        "caseworker-employment-loa1",
                        "caseworker-employment-tribunal-manchester-loa1",
                        "caseworker-employment-tribunal-glasgow-caseofficer-loa1",
                        "caseworker-employment-tribunal-glasgow-casesupervisor-loa1",
                        "caseworker-employment-tribunal-glasgow-loa1",
                        "caseworker-loa1"
                    ],
                    "defaultService": "CCD"
                }
            },
            "channels": nil,
            "jurisdictions": [],
            "default": {},
            "_links": {}
        }
        JSON.generate j
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

      def case_created_response(id, uid, jid, ctid)
        j = case_hash(ctid, id, jid)
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

      def unknown_event_error_for(r)
        j = {"timestamp":"2019-07-01T07:46:35.405+0000","status":400,"error":"Unknown event","message":"Unknown event","path": r.path}
        JSON.generate(j)
      end
    end
  end
end
