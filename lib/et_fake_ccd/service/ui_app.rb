require 'roda'
require 'json'
require 'et_fake_ccd/commands'
require 'et_fake_ccd/auth_service'
module EtFakeCcd
  module Service
    class UiApp < Roda
      plugin :request_headers
      plugin :halt
      plugin :render, layout: 'layout.html'
      route do |r|
        r.is "cases" do
          view("cases.html")
        end
      end
    end
  end
end
