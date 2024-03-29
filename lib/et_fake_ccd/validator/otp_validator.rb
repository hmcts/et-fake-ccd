require 'rotp'
module EtFakeCcd
  module Validator
    class OtpValidator < ActiveModel::EachValidator
      def initialize(options = {})
        secret = options[:secret] || ::EtFakeCcd.config.microservice_secret
        self.otp = ROTP::TOTP.new(secret)
        super(options.except(:secret))
      end

      def validate_each(record, attribute, value)
        record.errors.add :one_time_password, 'Invalid oneTimePassword' unless otp.verify(value, drift_behind: 15)
      end

      private

      attr_accessor :otp
    end
  end
end
