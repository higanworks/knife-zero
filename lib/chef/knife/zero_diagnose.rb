require 'chef/knife'
require 'chef/knife/bootstrap'
require 'chef/knife/zero_base'

class Chef
  class Knife
    class ZeroDiagnose < Knife
      include Chef::Knife::ZeroBase

      deps do
        require 'knife-zero/core/bootstrap_context'
        require 'chef/knife/zero_bootstrap'
        require 'chef/knife/zero_chef_client'
        Chef::Knife::ZeroBootstrap.load_deps
        Chef::Knife::ZeroChefClient.load_deps
      end

      banner "knife zero diagnose # show configuration from file"

      def initialize(argv = [])
        super
        @bootstrap = Chef::Knife::ZeroBootstrap.new
        @chef_client = Chef::Knife::ZeroChefClient.new
      end

      def run
        ui.msg "Chef::Config"
        ui.msg "===================="
        ui.msg Chef::Config.configuration.to_yaml
        ui.msg ""

        ui.msg "Knife::Config"
        ui.msg "===================="
        ui.msg config.to_yaml
        ui.msg ""

        ui.msg "Zero Bootstrap Config"
        ui.msg "===================="
        bootstrap = Chef::Knife::ZeroBootstrap.new
        @bootstrap.merge_configs
        ui.msg @bootstrap.config.to_yaml
        ui.msg ""

        ui.msg "Zero ChefClient Config"
        ui.msg "===================="
        @chef_client.merge_configs
        ui.msg @chef_client.config.to_yaml
      end
    end
  end
end
