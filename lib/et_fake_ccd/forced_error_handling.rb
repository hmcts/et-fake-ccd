require 'et_fake_ccd/request_store_service'
module EtFakeCcd
  module ForcedErrorHandling
    extend ActiveSupport::Concern

    def with_forced_error_handling(r, stage:)
      request_id = r.headers['request_id']
      RequestStoreService.store "#{stage}-#{request_id}" unless request_id.nil?
      count = request_id.nil? ? 1 : RequestStoreService.count("#{stage}-#{request_id}")
      specs = JSON.parse(r.headers['force_failures'] || '{}')
      spec = specs.fetch("#{stage}_stage", [])
      response_code = spec[count - 1].to_i
      if response_code.zero?
        yield
      else
        r.halt response_code
      end
    end
  end
end
