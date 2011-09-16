require File.join(File.dirname(__FILE__), 'spec_helper')

describe Statsd::Aggregator do

  before(:each) do
    @server = Statsd::Server.new('signature', Statsd::Runner.default_config)
  end

  it "should properly aggregate counters" do
    @server.receive_data('statsd.counter.test:1|c')

    @server.aggregate!.should == "stats.statsd.counter.test 0.1 0\nstats_counts.statsd.counter.test 1.0 0\nstatsd.numStats 1 0\n"
  end

  it "should properly aggregate timers" do
    @server.receive_data('statsd.timer.test:15|ms')
    @server.receive_data('statsd.timer.test:5|ms')
    @server.receive_data('statsd.timer.test:10|ms')
    @server.receive_data('statsd.timer.test:20|ms')

    @server.aggregate!.should == "stats.timers.statsd.timer.test.mean 12.5 0\nstats.timers.statsd.timer.test.upper 20.0 0\nstats.timers.statsd.timer.test.upper_90 20.0 0\nstats.timers.statsd.timer.test.lower 5.0 0\nstats.timers.statsd.timer.test.count 4 0\nstatsd.numStats 1 0\n"
  end

end
