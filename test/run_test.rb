base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir  = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test/unit")

$LOAD_PATH.unshift(lib_dir)

require 'test/unit'
require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join("..", "..", "..", ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
  SimpleCov.start do
    add_filter "/vendor/"
  end
end

exit Test::Unit::AutoRunner.run(true, test_dir)
