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
          r.is "caseworkers", Integer, "jurisdictions", String, "case-types", String, "cases" do |uid, jid, ctid|
            r.get do
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
    end
  end
end
