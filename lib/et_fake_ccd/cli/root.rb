require "thor"
module EtFakeCcd
  module Cli
    class Root < Thor
      desc "start_multiple", "Run multiple services on different ports"
      def start_multiple
        puts "Not yet written"
      end

      desc "start", "Run multiple services on one port"
      def start
        Rack::Server.start app: EtFakeCcd::RootApp
      end
    end
  end
end
