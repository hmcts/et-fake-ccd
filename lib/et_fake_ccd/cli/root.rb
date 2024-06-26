require "thor"
require 'puma'
require 'puma/configuration'
module EtFakeCcd
  module Cli
    class Root < Thor
      desc "start_multiple", "Run multiple services on different ports"
      def start_multiple
        puts "Not yet written"
      end

      desc "start", "Run multiple services on one port"
      method_option :port, type: :numeric, default: 8080
      method_option :create_case_schema, type: :string, default: ENV.fetch('ET_FAKE_CCD_CREATE_CASE_SCHEMA', nil)

      def start
        if options.create_case_schema && !File.exist?(options.create_case_schema)
          puts "Error - The file #{options.create_case_schema} does not exist."
          return
        end
        ::EtFakeCcd.config do |c|
          c.create_case_schema_file = options.create_case_schema
        end
        conf = Puma::Configuration.new do |user_config|
          user_config.threads 1, 1
          user_config.workers 1
          user_config.port options.port
          user_config.app { EtFakeCcd::RootApp }
        end
        Puma::Launcher.new(conf, log_writer: Puma::LogWriter.stdio).run
      end
    end
  end
end
