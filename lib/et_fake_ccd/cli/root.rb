require "thor"
require "et_fake_ccd/iodine"
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
        Rack::Server.start app: EtFakeCcd::RootApp, Port: options.port, server: 'iodine'
      end
    end
  end
end
