require 'chef/knife/zero_base'
require 'knife-zero/helper'

class TC_ZeroHelper < Test::Unit::TestCase
  def setup
    @config = Chef::Config
  end

  test "Should returns 18889 as zero_remote_port by default" do
    assert_equal(18889, ::Knife::Zero::Helper.zero_remote_port)
  end

  sub_test_case "override" do
    test "Should returns 10000 + chef_zero_port as zero_remote_port" do
      @config[:chef_zero_port] = 2500
      assert_equal(12500, ::Knife::Zero::Helper.zero_remote_port)
    end

    test "Should returns 10000 + knife:chef_zero_port as zero_remote_port" do
      @config[:knife][:chef_zero_port] = 2500
      assert_equal(12500, ::Knife::Zero::Helper.zero_remote_port)
    end

    def teardown
      @config[:chef_zero_port] = nil
      @config[:knife][:chef_zero_port] = nil
    end
  end

  sub_test_case "force set by remote_chef_zero_port" do

    test "Should returns passed remote_chef_zero_port as zero_remote_port" do
      @config[:remote_chef_zero_port] = 8888
      @config[:chef_zero_port] = 2500
      assert_equal(8888, ::Knife::Zero::Helper.zero_remote_port)
    end

    def teardown
      @config[:remote_chef_zero_port] = nil
      @config[:chef_zero_port] = nil
    end
  end
end
