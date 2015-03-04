require 'chef/knife/zero_bootstrap'

class TC_ZeroBootstrap < Test::Unit::TestCase
  sub_test_case "called with no options" do
    def setup
      @app = Chef::Knife::ZeroBootstrap.new
      @app.merge_configs
    end

    test "returns changed value from core" do
      assert_equal(@app.config[:distro], "chef-full-localmode")
    end
  end
end
