require 'test/unit'
require 'set'
require 'rubygems'
require 'active_record'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
gem 'thoughtbot-shoulda'
require 'shoulda'
gem 'mocha'
require 'mocha'

$:.unshift "#{File.dirname(__FILE__)}/../lib"

require "#{File.dirname(__FILE__)}/../init"
