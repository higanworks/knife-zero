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
        @converge = Chef::Knife::ZeroConverge.new
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

        ui.msg "Zero Converge Config"
        ui.msg "===================="
        @converge.merge_configs
        ui.msg @converge.config.to_yaml
      end
    end
  end
end
