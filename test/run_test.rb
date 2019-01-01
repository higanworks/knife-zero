#!/usr/bin/env ruby
base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir  = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test")

$LOAD_PATH.unshift(lib_dir)

require 'test/unit'
require 'test/unit/rr'
require 'simplecov'
require 'simplecov-rcov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join("..", "..", "..", ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start do
    add_filter "/vendor/"
    add_filter "/test/"
  end
else
  require "test/unit/notify"
end

exit Test::Unit::AutoRunner.run(true, test_dir)
