require 'test/unit'
require 'mocha'

require File.expand_path(File.dirname(__FILE__) + '/../lib/e_shipper_ruby')

$client = EShipper::Client.instance