##
# Sends statistics to the stats daemon over UDP
#

require 'socket'

module Statsd
  class Client
    class << self
      @@host = '127.0.0.1'
      @@port = 8125

      def configure(host, port)
        @@host = host
        @@port = port

        true
      end

      ##
      # Log timing information
      #
      # @param string stats The metric to in log timing info for.
      # @param float time The ellapsed time (ms) to log
      # @param float|1 sample_rate the rate (0-1) for sampling.
      #
      def timing(stat, time, sample_rate=1)
        self.send({stat => "#{time}|ms"}, sample_rate)
      end

      ##
      # Increments one or more stats counters
      #
      # @param string|array stats The metric(s) to increment.
      # @param float|1 sample_rate the rate (0-1) for sampling.
      # @return boolean
      #
      def increment(stats, sample_rate=1)
        self.update_stats(stats, 1, sample_rate)
      end

      ##
      # Decrements one or more stats counters.
      #
      # @param string|array stats The metric(s) to decrement.
      # @param float|1 sample_rate the rate (0-1) for sampling.
      # @return boolean
      #
      def decrement(stats, sample_rate=1)
        self.update_stats(stats, -1, sample_rate)
      end

      ##
      # Updates one or more stats counters by arbitrary amounts.
      #
      # @param string|array stats The metric(s) to update. Should be either a string or array of metrics.
      # @param int|1 delta The amount to increment/decrement each metric by.
      # @param float|1 sample_rate the rate (0-1) for sampling.
      # @return boolean
      #
      def update_stats(stats, delta=1, sample_rate=1)
        stats = [stats] unless stats.is_a?(Array)
        data = stats.inject({}) do |m,stat|
          m[stat] = "#{delta}|c"
          m
        end

        self.send(data, sample_rate)
      end

      ##
      # Squirt the metrics over UDP
      #
      def send(data, sample_rate=1)
        sampled_data = {}

        if (sample_rate < 1)
          data.each_pair do |stat, value|
            if rand <= sample_rate
              sampled_data[stat] = "#{value}|@#{sample_rate}"
            end
          end
        else
          sampled_data = data
        end

        return if sampled_data.empty?

        # Wrap this in a try/catch - failures in any of this should be silently ignored
        begin
          s = UDPSocket.new
          sampled_data.each_pair do |stat, value|
            s.send("#{stat}:#{value}", 0, @@host, @@port)
          end
        rescue
          # safe to ignore issues
        end
      end

    end
  end
end
