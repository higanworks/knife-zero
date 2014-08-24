require 'chef/knife'
require 'chef/knife/zero_base'

class Chef
  class Knife
    class ZeroChefClient < Chef::Knife::Ssh
      include Chef::Knife::ZeroBase
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

      def run
        configure_attribute
        configure_user
        configure_password
        configure_identity_file
        list = search_nodes

        list.each do |n|
          Chef::Log.debug("Start session for #{n}")
          session = knife_ssh
          session.configure_session(n)
          session.ssh_command(start_chef_client)
        end
      end

      def start_chef_client
        client_path = @config[:chef_client_path] || 'chef-client'
        s = "#{client_path}"
        s << ' -l debug' if @config[:verbosity] and @config[:verbosity] >= 2
        s << " -S http://127.0.0.1:8889"
        s
      end
    end
  end
end
