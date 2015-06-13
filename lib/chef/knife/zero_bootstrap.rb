require 'chef/knife'
require 'chef/knife/bootstrap'
require 'chef/knife/zero_base'

class Chef
  class Knife
    class ZeroBootstrap < Chef::Knife::Bootstrap
      include Chef::Knife::ZeroBase
      deps do
        require 'knife-zero/core/bootstrap_context'
        require 'knife-zero/bootstrap_ssh'
        Chef::Knife::BootstrapSsh.load_deps
      end

      banner "knife zero bootstrap FQDN (options)"

      ## Import from knife bootstrap except exclusions
      self.options = Bootstrap.options
      self.options.delete :node_ssl_verify_mode
      self.options.delete :node_verify_api_cert

      def knife_ssh
        begin
        ssh = Chef::Knife::BootstrapSsh.new
        ssh.ui = ui
        ssh.name_args = [ server_name, ssh_command ]
        ssh.config = Net::SSH.configuration_for(server_name)
        ssh.config[:ssh_user] = config[:ssh_user] || Chef::Config[:knife][:ssh_user]
        ssh.config[:ssh_password] = config[:ssh_password]
        ssh.config[:ssh_port] = config[:ssh_port] || Chef::Config[:knife][:ssh_port]
        ssh.config[:ssh_gateway] = config[:ssh_gateway] || Chef::Config[:knife][:ssh_gateway]
        ssh.config[:forward_agent] = config[:forward_agent] || Chef::Config[:knife][:forward_agent]
        ssh.config[:identity_file] = config[:identity_file] || Chef::Config[:knife][:identity_file]
        ssh.config[:manual] = true
        ssh.config[:host_key_verify] = config[:host_key_verify] || Chef::Config[:knife][:host_key_verify]
        ssh.config[:on_error] = :raise
        ssh
        rescue => e
          ui.error(e.class.to_s + e.message)
          ui.error e.backtrace.join("\n")
          exit 1
        end
      end
    end
  end
end
