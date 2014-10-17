require 'chef/knife'
require 'chef/knife/zero_base'
require 'knife-zero/helper'

class Chef
  class Knife
    class ZeroChefClient < Chef::Knife::Ssh
      include Chef::Knife::ZeroBase
      include ::Knife::Zero::Helper

      deps do
        require 'chef/node'
        require 'chef/environment'
        require 'chef/api_client'
        require 'chef/search/query'
        require 'knife-zero/bootstrap_ssh'
        Chef::Knife::BootstrapSsh.load_deps
      end

      banner "knife zero chef_client QUERY (options)"

      option :attribute,
        :short => "-a ATTR",
        :long => "--attribute ATTR",
        :description => "The attribute to use for opening the connection - default depends on the context",
        :proc => Proc.new { |key| Chef::Config[:knife][:ssh_attribute] = key.strip }

      option :use_sudo,
        :long => "--sudo",
        :description => "execute the chef-client via sudo",
        :boolean => true

      option :concurrency,
        :short => "-C NUMBER",
        :long => "--concurrency NUMBER",
        :description => "Number of concurrency. (default: 1) ; not avaiable on some platforms like Windows and NetBSD 4.",
        :proc => lambda { |s| s.to_i },
        :default => 1

      def run
        configure_attribute
        configure_user
        configure_password
        configure_identity_file
        list = search_nodes

        pids = []
        list.each do |n|
          # Note: fork(2) is not avaiable on some platforms like Windows and NetBSD 4. 
          if (Process.respond_to?(:fork) && !Chef::Platform.windows?)
            pids << Process.fork {
              Chef::Log.debug("Start session for #{n}")
              session = knife_ssh
              session.configure_session(n)
              session.ssh_command(start_chef_client)
            }
            until count_alive_pids(pids) < @config[:concurrency]
              sleep 1
            end
          else
            Chef::Log.debug("Start session for #{n}")
            session = knife_ssh
            session.configure_session(n)
            session.ssh_command(start_chef_client)
          end
        end

        result = Process.waitall
        ## NOTE: should report if includes fail...?
      end

      def start_chef_client
        client_path = @config[:use_sudo] ? 'sudo ' : ''
        client_path = @config[:chef_client_path] ? "#{client_path}#{@config[:chef_client_path]}" : "#{client_path}chef-client" 
        s = "#{client_path}"
        s << ' -l debug' if @config[:verbosity] and @config[:verbosity] >= 2
        s << " -S http://127.0.0.1:8889"
        s << " -W" if @config[:why_run]
        s
      end
    end
  end
end
