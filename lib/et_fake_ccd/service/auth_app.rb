require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
require 'et_fake_ccd/forced_error_handling'
module EtFakeCcd
  module Service
    class AuthApp < Roda
      include EtFakeCcd::ForcedErrorHandling
      plugin :request_headers
      plugin :halt
      route do |r|
        r.is "lease" do
          with_forced_error_handling(r, stage: :token) do
            r.post do
              command = ::EtFakeCcd::Command::LeaseCommand.from_json JSON.parse(r.body.read)
              if command.valid?
                ::EtFakeCcd::AuthService.generate_service_token
              else
                r.halt 403, render_error_for(command)
              end
            end
          end
        end
      end

      private

      def render_error_for(command)
        if command.errors.include?(:one_time_password)
          {message: 'Invalid one-time password'}.to_json
        else
          {message: command.errors.map(&:message).join(', ') }
        end
      end


    end
  end
end
