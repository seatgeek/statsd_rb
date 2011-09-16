module Statsd
  class Publisher < EM::Connection

    def initialize(server)
      @server = server
    end

    def post_init
      send_data(@server.aggregate!)
      close_connection_after_writing
    end

  end
end
