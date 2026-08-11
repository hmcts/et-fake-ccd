require 'roda'
require 'json'
require 'rack/utils'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/data_store_service'
module EtFakeCcd
  module Service
    class UiApp < Roda
      plugin :request_headers
      plugin :halt
      plugin :render, layout: 'layout.html', cache: false
      plugin :partials
      route do |r|
        r.root do
          view("home.html")
        end

        r.is "cases" do
          page_size = 25
          filters = r.params.dup
          page = (filters.delete('page') || "1").to_i
          sort_direction = filters.delete('sortDirection') || 'asc'
          jid = filters.delete('jid') || 'EMPLOYMENT'
          ctid = filters.delete('ctid') || 'Glasgow_Dev'
          filters.delete_if { |k, v| v.nil? || v.empty? }
          list = DataStoreService.list(jid:, ctid:, filters: filters, page:, sort_direction: sort_direction, page_size:)
          total_pages = (DataStoreService.total_count(jid:, ctid:, filters:) / page_size.to_f).ceil
          case_types = DataStoreService.case_types(jid:)

          view("cases.html", locals: {
            cases: list,
            case_types:,
            jid:,
            ctid:,
            page_size:,
            page:,
            total_pages:,
            filters:,
            pagination_query: pagination_query(jid:, ctid:, sort_direction:, filters:),
            pagination_items: pagination_items(page:, total_pages:)
          })
        end

        r.is "cases/case-details", String, String, String do |jid, ctid, case_id|
          case_data = DataStoreService.find_case_data_by_id(case_id, jid:, ctid:)
          unless case_data
            response.status = 404
            next view("case-not-found.html", locals: {case_id:})
          end

          if ctid =~ /_Multiples/
            lead_cases = DataStoreService.list(jid:, ctid: ctid.gsub(/_Multiples/, ''), filters: {'data.multipleReference' => case_data&.dig('data', 'multipleReference'), 'data.leadClaimant' => 'Yes', 'data.caseType' => 'Multiple'})
            view("case-details-multiples.html", locals: {
              jid:,
              ctid:,
              case_data:,
              case_id:,
              lead_case: lead_cases.values.first,
              lead_case_id: lead_cases.keys.first
            })

          else
            view("case-details.html", locals: {
              jid:,
              ctid:,
              case_data:,
              case_id:
            })
          end
        end
      end

      private

      def pagination_query(jid:, ctid:, sort_direction:, filters:)
        params = filters.merge(
          'jid' => jid,
          'ctid' => ctid,
          'sortDirection' => sort_direction
        )
        Rack::Utils.escape_html(Rack::Utils.build_query(params))
      end

      def pagination_items(page:, total_pages:)
        return (1..total_pages).to_a if total_pages <= 7
        return [1, 2, 3, 4, 5, :ellipsis, total_pages] if page <= 4
        return [1, :ellipsis, *(total_pages - 4..total_pages)] if page >= total_pages - 3

        [1, :ellipsis, page - 1, page, page + 1, :ellipsis, total_pages]
      end
    end
  end
end
