require 'chef/knife'
require 'chef/knife/zero_chef_client'

class Chef
  class Knife
    class ZeroConverge < Chef::Knife::ZeroChefClient
      deps do
        Chef::Knife::ZeroChefClient.load_deps
      end

      banner "knife zero converge QUERY (options) | It's alias of chef_client."
      self.options = ZeroChefClient.options
    end
  end
end
