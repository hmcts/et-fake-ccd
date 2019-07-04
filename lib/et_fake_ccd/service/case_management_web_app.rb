require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
module EtFakeCcd
  module Service
    class CaseManagementWebApp < Roda
      plugin :request_headers
      plugin :halt
      plugin :render
      route do |r|
        r.is "oauth2redirect" do
          r.get do
            ""
          end
        end
        r.is "config" do
          r.get do
            config_result
          end
        end
      end

      private

      def config_result
        j = {
            "login_url": url_for("/authentication-web/login"),
            "logout_url": url_for("/api-gateway/logout"),
            "api_url": url_for("/api-gateway/aggregated"),
            "case_data_url": url_for("/api-gateway/data"),
            "document_management_url": url_for("/api-gateway/documents"),
            "pagination_page_size": 25,
            "oauth2_token_endpoint_url": url_for("/api-gateway/oauth2"),
            "oauth2_client_id": url_for("ccd_gateway")
        }
        JSON.generate(j)
      end

      def url_for(path)
        uri = Addressable::URI.parse(request.url)
        uri.path = path
        uri.to_s
      end

      def config
        EtFakeCcd.config
      end
    end
  end
end
