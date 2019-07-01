require 'active_model'
module EtFakeCcd
  module Command
    class LoginUserCommand
      include ActiveModel::Model
      include ActiveModel::Attributes

      def initialize(config: ::EtFakeCcd::Config.instance, **args)
        self.config = config
        super(**args)
      end

      attribute :username
      attribute :password

      def self.from_json(json)
        new username: json['username'], password: json['password']
      end

      validate :validate_username_and_password

      private

      attr_accessor :config

      def validate_username_and_password
        return if config.valid_credentials.any? do |cred|
          username == cred[:username] && password == cred[:password]
        end
        errors.add(:username, "Invalid username or password")
      end

    end
  end
end
