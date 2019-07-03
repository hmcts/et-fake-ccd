require 'singleton'
module EtFakeCcd
  class Config
    include Singleton

    attr_accessor :microservice, :microservice_secret, :valid_credentials, :oauth2_client_id, :oauth2_redirect_url
  end

  Config.instance.tap do |c|
    c.microservice = 'ccd_gw'
    c.microservice_secret = 'AAAAAAAAAAAAAAAC'
    c.valid_credentials = [
        {username: 'm@m.com', password: 'p'}
    ]
    c.oauth2_client_id = "ccd_gateway"
    c.oauth2_redirect_url = "http://localhost:3451/oauth2redirect" # The contents of this at the moment are not important
  end
end
