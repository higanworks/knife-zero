require 'knife-zero/bootstrap_ssh'

class TC_BootstrapSsh < Test::Unit::TestCase
  def setup
    @app = Chef::Knife::BootstrapSsh.new
    @app.merge_configs
  end
end
