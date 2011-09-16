##
# Quick helper script to load up everything
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'rspec'
require 'statsd'

$DEBUG   = ENV['DEBUG'] === 'true'
$TESTING = true
