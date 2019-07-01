require "et_fake_ccd/version"
require "et_fake_ccd/config"
require "et_fake_ccd/root_app"
require "et_fake_ccd/service/sidam_app"

module EtFakeCcd
  class Error < StandardError; end
  # Your code goes here...
  #
  def self.config
    Config.instance
  end
end

