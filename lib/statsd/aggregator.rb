module Statsd
  module Aggregator

    def aggregate!
      stat_string = ''
      ts          = $TESTING ? 0 : Time.new.to_i
      num_stats   = 0

      @counters.each do |k,v|
        val = v / (@config[:flush_interval])
        stat_string << "stats.%s %s %d\n"        % [ k, val, ts ]
        stat_string << "stats_counts.%s %s %d\n" % [ k, v, ts ]

        @counters[k] = 0
        num_stats   += 1
      end

      @timers.each do |k,v|
        pct_thresh  = @config[:threshold_pct]
        values      = v.sort { |a,b| a-b }
        min         = values.first
        max         = values.last

        mean          = min
        max_at_thresh = max

        if values.size > 1
          thresh_idx    = (((100-pct_thresh)/100) * values.length).round
          num_in_thresh = values.length - thresh_idx

          values = values.slice(0, num_in_thresh)
          max_at_thresh = values.last

          # avg remaining times
          mean = values.reduce(0, :+) / num_in_thresh
        end

        @timers[k] = []

        stat_string << [
          "stats.timers.%s.mean %s %d\n"      % [ k, mean, ts ],
          "stats.timers.%s.upper %s %d\n"     % [ k, max, ts ],
          "stats.timers.%s.upper_%d %s %d\n"  % [ k, pct_thresh, max_at_thresh, ts ],
          "stats.timers.%s.lower %s %d\n"     % [ k, min, ts ],
          "stats.timers.%s.count %s %d\n"     % [ k, values.length, ts ],
        ].join('')

        num_stats += 1
      end

      stat_string << "statsd.numStats %d %d\n" % [ num_stats, ts ]
      $stderr.puts stat_string if (@config[:debug])

      stat_string
    end
  end

end
