require 'chef/knife/ssh'

class Chef
  class Knife
    class BootstrapSsh < Chef::Knife::Ssh
      deps do
        Chef::Knife::Ssh.load_deps
        require "knife-zero/net-ssh-multi-patch"
        require "knife-zero/helper"
      end

      def ssh_command(command, subsession=nil)
        begin

        if config[:client_version]
          super(%Q{/opt/chef/embedded/bin/ruby -ropen-uri -e 'puts open("https://chef.sh").read' | sudo sh -s -- -v #{config[:client_version]}})
        end

        chef_zero_port = config[:chef_zero_port] ||
                         Chef::Config[:knife][:chef_zero_port] ||
                         URI.parse(Chef::Config.chef_server_url).port
        chef_zero_host = config[:chef_zero_host] ||
                         Chef::Config[:knife][:chef_zero_host] ||
                        '127.0.0.1'
        (subsession || session).servers.each do |server|
          session = server.session(true)
          session.forward.remote(chef_zero_port, chef_zero_host, ::Knife::Zero::Helper.zero_remote_port)
        end
        super
        rescue => e
          ui.error(e.class.to_s + e.message)
          ui.error e.backtrace.join("\n")
          exit 1
        end
      end
    end
  end
end
