require "roda"
require "et_fake_ccd/service/sidam_app"
require "et_fake_ccd/service/auth_app"
require "et_fake_ccd/service/data_store_app"
module EtFakeCcd
  class RootApp < Roda
    plugin :multi_run
    run "idam", Service::SidamApp
    run "auth", Service::AuthApp
    run "data_store", Service::DataStoreApp

    route do |r|
      r.multi_run
    end
  end
end
