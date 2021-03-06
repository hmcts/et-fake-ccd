require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/forced_error_handling'
module EtFakeCcd
  module Service
    class AuthenticationWebApp < Roda
      include EtFakeCcd::ForcedErrorHandling
      plugin :request_headers
      plugin :halt
      plugin :render
      route do |r|
        r.is "login" do
          r.get do
            with_forced_error_handling(r, stage: :token) do
              file = File.absolute_path(File.join('..', 'views', 'login.html.erb'), __dir__)
              render(path: file, locals: { oauth2_redirect_url: config.oauth2_redirect_url, oauth2_client_id: config.oauth2_client_id })
            end
          end
          r.post do
            with_forced_error_handling(r, stage: :token) do
              command = ::EtFakeCcd::Command::LoginUserCommand.from_json(r.params)
              if command.valid?
                r.redirect "/case-management-web/oauth2redirect?code=pfSHb6v4dEDEfqqP"
              else
                r.halt 401, "Access Denied"
              end
            end
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
