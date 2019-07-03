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
      end

      private

      def config
        EtFakeCcd.config
      end
    end
  end
end
