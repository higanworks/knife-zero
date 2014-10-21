require 'chef/knife/ssh'

class Chef
  class Knife
    class BootstrapSsh < Chef::Knife::Ssh
      def ssh_command(command, subsession=nil)
        chef_zero_port = config[:chef_zero_port] ||
                         Chef::Config[:knife][:chef_zero_port] ||
                         8889
        chef_zero_host = config[:chef_zero_host] ||
                         Chef::Config[:knife][:chef_zero_host] ||
                        '127.0.0.1'
        (subsession || session).servers.each do |server|
          session = server.session(true)
          session.forward.remote(8889, chef_zero_host, chef_zero_port)
        end
        super
      end
    end
  end
end

