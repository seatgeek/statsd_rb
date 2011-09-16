$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))

require 'statsd'

##
# If we are being run directly, fire off the server
#
if __FILE__ == $0
  Statsd::Runner.run!({ :debug => true })
end

__END__

Etsy's storage.conf:

[10s_for_24h__1m_for_30d__10m_for_5y]
priority = 100
pattern = .*
retentions = 10:2160,60:43200,600:262974
