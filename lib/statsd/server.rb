module Statsd
  class Server < EM::Connection
    include Aggregator

    attr_reader :config, :counters, :timers

    def initialize(config)
      @config   = config
      @timers   = {}
      @counters = {}
    end

    def receive_data(msg)
      $stderr.puts msg if (@config[:debug])

      bits = msg.split(':')
      key  = bits.first.gsub(/\s+/, '_').gsub(/\//, '-').gsub(/[^a-zA-Z_\-0-9\.]/, '')

      bits << '1' if bits.empty?

      bits.each do |b|
        next unless b.include? '|'

        sample_rate = 1
        fields      = b.split('|')

        if fields[1]
          case fields[1].strip
          when 'ms'
            @timers[key] ||= []
            @timers[key] << fields[0].to_f || 0
          when 'c'
            /^@([\d\.]+)/.match(fields[2]) {|m| sample_rate = m[1].to_f }

            @counters[key] ||= 0
            @counters[key] += (fields[0].to_f || 1) * (1/sample_rate)
          else
            # do nothing
            $stderr.puts "Unsupported type: #{msg}" if (@config[:debug])
          end
        else
          $stderr.puts "Invalid line: #{msg}" if (@config[:debug])
        end
      end
    end

  end
end
