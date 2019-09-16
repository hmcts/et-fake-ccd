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
      def start
        Rack::Server.start app: EtFakeCcd::RootApp, Port: options.port, server: 'iodine'
      end
    end
  end
end
