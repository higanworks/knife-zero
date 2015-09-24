require 'chef/knife'
require 'chef/knife/zero_converge'

class Chef
  class Knife
    class ZeroChefClient < Chef::Knife::ZeroConverge
      deps do
        Chef::Knife::ZeroConverge.load_deps
      end

      banner "knife zero chef_client QUERY (options) | It's same as converge"
      self.options = ZeroConverge.options

      def run
        Chef::Log.warn "`zero chef_client` was renamed. use `zero converge`."
        super
      end
    end
  end
end
