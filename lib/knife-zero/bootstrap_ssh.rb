require 'chef/knife/ssh'

class Chef
  class Knife
    class BootstrapSsh < Chef::Knife::Ssh
      deps do
        Chef::Knife::Ssh.load_deps
        require "knife-zero/net-ssh-multi-patch"
      end

      def ssh_command(command, subsession=nil)
        chef_zero_port = config[:chef_zero_port] ||
                         Chef::Config[:knife][:chef_zero_port] ||
                         URI.parse(Chef::Config.chef_server_url).port
        chef_zero_host = config[:chef_zero_host] ||
                         Chef::Config[:knife][:chef_zero_host] ||
                        '127.0.0.1'
        (subsession || session).servers.each do |server|
          session = server.session(true)
          session.forward.remote(chef_zero_port, chef_zero_host, chef_zero_port)
        end
        super
      end
    end
  end
end
