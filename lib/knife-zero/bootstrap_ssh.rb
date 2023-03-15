require 'chef/knife/ssh'
require 'chef/knife/version'

class Chef
  class Knife
    class BootstrapSsh < Chef::Knife::Ssh
      deps do
        Chef::Knife::Ssh.load_deps
        require 'knife-zero/net_ssh_multi_patch'
        require 'knife-zero/helper'
      end

    if Gem::Version.new(Chef::Knife::VERSION) < Gem::Version.new("17.3.27")
      def ssh_command(command, subsession = nil) # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
        if config[:client_version]
          case config[:alter_project]
          when 'cinc'
            super(%{/opt/cinc/embedded/bin/ruby -ropen-uri -e 'puts open("https://omnitruck.cinc.sh/install.sh").read' | sudo sh -s -- -v #{config[:client_version]}})
          else
            super(%{/opt/chef/embedded/bin/ruby -ropen-uri -e 'puts open("https://omnitruck.chef.io/chef/install.sh").read' | sudo sh -s -- -v #{config[:client_version]}})
          end
        end

        if config[:json_attribs]
          Chef::Log.info "Onetime Attributes: #{config[:chef_client_json]}"
          super(build_client_json)
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
      rescue => e # rubocop:disable Style/RescueStandardError
        ui.error(e.class.to_s + e.message)
        ui.error e.backtrace.join("\n")
        exit 1
      end
    else
      def ssh_command(command, session_list = session) # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
        if config[:client_version]
          case config[:alter_project]
          when 'cinc'
            super(%{/opt/cinc/embedded/bin/ruby -ropen-uri -e 'puts open("https://omnitruck.cinc.sh/install.sh").read' | sudo sh -s -- -v #{config[:client_version]}})
          else
            super(%{/opt/chef/embedded/bin/ruby -ropen-uri -e 'puts open("https://omnitruck.chef.io/chef/install.sh").read' | sudo sh -s -- -v #{config[:client_version]}})
          end
        end

        if config[:json_attribs]
          Chef::Log.info "Onetime Attributes: #{config[:chef_client_json]}"
          super(build_client_json)
        end

        chef_zero_port = config[:chef_zero_port] ||
                         Chef::Config[:knife][:chef_zero_port] ||
                         URI.parse(Chef::Config.chef_server_url).port
        chef_zero_host = config[:chef_zero_host] ||
                         Chef::Config[:knife][:chef_zero_host] ||
                         '127.0.0.1'
        session_list.servers.each do |server|
          session = server.session(true)
          session.forward.remote(chef_zero_port, chef_zero_host, ::Knife::Zero::Helper.zero_remote_port)
        end
        super
      rescue => e # rubocop:disable Style/RescueStandardError
        ui.error(e.class.to_s + e.message)
        ui.error e.backtrace.join("\n")
        exit 1
      end
    end

      def build_client_json
        <<-SCRIPT
        sudo sh -c 'cat <<"EOP" > /etc/#{ChefUtils::Dist::Infra::DIR_SUFFIX}/chef_client_json.json
        #{config[:chef_client_json].to_json}
        '
        SCRIPT
      end
    end
  end
end
