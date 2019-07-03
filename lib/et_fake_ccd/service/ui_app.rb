require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
module EtFakeCcd
  module Service
    class UiApp < Roda
      plugin :request_headers
      plugin :halt
      route do |r|
        r.is "config" do
          r.get do
            config_result
          end
        end
      end

      private

      def config_result
        j = {
            "login_url": "http://localhost:8080/authentication-web/login",
            "logout_url": "http://localhost:8080/api-gateway/logout",
            "api_url": "http://localhost:8080/api-gateway/aggregated",
            "case_data_url": "http://localhost:8080/api-gateway/data",
            "document_management_url": "http://localhost:8080/api-gateway/documents",
            "pagination_page_size": 25,
            "oauth2_token_endpoint_url": "http://localhost:8080/api-gateway/oauth2",
            "oauth2_client_id": "ccd_gateway"
        }
        JSON.generate(j)
      end
    end
  end
end
