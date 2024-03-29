require "roda"
require "et_fake_ccd/service/sidam_app"
require "et_fake_ccd/service/auth_app"
require "et_fake_ccd/service/data_store_app"
require "et_fake_ccd/service/document_store_app"
require "et_fake_ccd/service/authentication_web_app"
require "et_fake_ccd/service/case_management_web_app"
require "et_fake_ccd/service/api_gateway_web_app"
require "et_fake_ccd/service/ecm_app"
module EtFakeCcd
  class RootApp < Roda
    plugin :multi_run
    plugin :enhanced_logger
    run "idam", Service::SidamApp
    run "auth", Service::AuthApp
    run "data_store", Service::DataStoreApp
    run "document_store", Service::DocumentStoreApp
    run "authentication-web", Service::AuthenticationWebApp
    run "case-management-web", Service::CaseManagementWebApp
    run "api-gateway", Service::ApiGatewayWebApp
    run "ecm", Service::EcmApp

    route do |r|
      r.multi_run
    end
  end
end
