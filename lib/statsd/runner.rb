module Statsd
  class Runner

    def self.default_config
      {
        :host           => "0.0.0.0",
        :port           => 8125,
        :daemonize      => false,
        :debug          => false,
        :flush_interval => 10,
        :threshold_pct  => 90,

        :graphite_host  => '127.0.0.1',
        :graphite_port  => 2003
      }
    end

    def self.run!(opts = {})
      config = self.default_config.merge(opts)

      EM::run do
        server = EM::open_datagram_socket(config[:host], config[:port], Server, config)

        EM::add_periodic_timer(config[:flush_interval]) do
          begin
            EM::connect(config[:graphite_host], config[:graphite_port], Publisher, server)
          rescue
            $stderr.puts "Unable to connect to %s:%s" % [ config[:graphite_host], config[:graphite_port] ] if config[:debug]
          end
        end

        if config[:daemonize]
          app_name = 'statsd %s:%d' % config[:host], config[:port]
          Daemons.daemonize(:app_name => app_name)
        else
          puts "Now accepting connections on address #{config[:host]}, port #{config[:port]}..."
        end
      end
    end

  end
end
