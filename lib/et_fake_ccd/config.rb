require 'singleton'
module EtFakeCcd
  class Config
    include Singleton

    attr_accessor :microservice, :microservice_secret, :valid_credentials
  end

  Config.instance.tap do |c|
    c.microservice = 'ccd_gw'
    c.microservice_secret = 'AAAAAAAAAAAAAAAC'
    c.valid_credentials = [
        {username: 'm@m.com', password: 'p'}
    ]
  end
end
