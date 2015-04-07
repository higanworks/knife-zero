module Knife
  module Zero
    module Helper
      def self.zero_remote_port
        return ::Chef::Config[:remote_chef_zero_port] if ::Chef::Config[:remote_chef_zero_port]
        chef_zero_port = ::Chef::Config[:chef_zero_port] ||
                         ::Chef::Config[:knife][:chef_zero_port] ||
                         8889
        chef_zero_port + 10000
      end
    end
  end
end
