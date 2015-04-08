require 'chef/knife/zero_chef_client'
require 'knife-zero/core/bootstrap_context'

class TC_BootstrapContext < Test::Unit::TestCase
  def setup
    Chef::Config[:validation_key] = nil
    app = Chef::Knife::ZeroBootstrap.new
    app.merge_configs
    @bsc = Chef::Knife::Core::BootstrapContext.new(app.config, [], Chef::Config.configuration)
    stub(OpenSSL::PKey::RSA).new{"knife-zerozero"}
  end

  test "Should use aliased validation_key" do
    assert_equal("knife-zerozero", @bsc.validation_key)
  end

  test "Should use aliased start_chef" do
    assert_match('-S http://127.0.0.1', @bsc.start_chef)
  end
end
