require 'chef/knife/zero_chef_client'
class TC_ZeroChefClient < Test::Unit::TestCase
  sub_test_case "called with no options" do
    def setup
      @app = Chef::Knife::ZeroChefClient.new
      @app.merge_configs
    end

    test "returns true from Chef::Config[:knife_zero]" do
      assert(Chef::Config[:knife_zero])
    end

    test "returns changed value from core" do
      assert_nil(@app.config[:concurrency])
      assert_nil(@app.config[:override_runlist])
    end
  end
end
