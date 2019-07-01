require 'active_model'
require 'et_fake_ccd/validator/otp_validator.rb'
module EtFakeCcd
  module Command
    class LeaseCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      def initialize(config: ::EtFakeCcd::Config.instance, **args)
        self.config = config
        super(**args)
      end

      attribute :one_time_password
      attribute :microservice

      def self.from_json(json)
        new one_time_password: json['oneTimePassword'], microservice: json['microservice']
      end

      validates :one_time_password, "et_fake_ccd/validator/otp": { secret: EtFakeCcd::Config.instance.microservice_secret }

      private

      attr_accessor :config

    end
  end
end
