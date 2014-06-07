require 'rubygems'
require 'bundler/setup'
require 'active_resource'
require 'active_support'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'cached_resource'

RSpec.configure
