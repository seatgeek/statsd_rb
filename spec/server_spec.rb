require File.join(File.dirname(__FILE__), 'spec_helper')

describe Statsd::Server do

  describe "Receiving data" do

    before(:each) do
      @server = Statsd::Server.new('signature', Statsd::Runner.default_config)
    end

    it "should properly handle counters" do
      @server.receive_data('statsd.counter.test:1|c')

      @server.counters['statsd.counter.test'].should == 1
      @server.timers.should == {}
    end

    it "should properly handle timers" do
      @server.receive_data('statsd.timer.test:20|ms')

      @server.timers['statsd.timer.test'].should == [20]
      @server.counters.should == {}
    end

    it "should properly handle invalid input" do
      @server.receive_data('statsd.invalid.test :1|x')
      @server.receive_data('statsd.invalid.test :1|2')

      @server.counters.should == {}
      @server.timers.should == {}
    end

  end

end
