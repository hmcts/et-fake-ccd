# frozen_string_literal: true

module EtFakeCcd
  class LoggerProxy
    def log(*args, **kw_args)
      logger.send(logger_method, *args, **kw_args)
    end

    private

    def logger
      @logger||= Config.instance.logger
    end

    def logger_method
      @logger_method ||= Config.instance.logger_method
    end
  end
end
