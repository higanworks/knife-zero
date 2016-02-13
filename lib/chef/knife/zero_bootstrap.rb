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

      banner "knife zero bootstrap [SSH_USER@]FQDN (options)"

      ## Import from knife bootstrap except exclusions
      self.options = Bootstrap.options.merge(self.options)
      self.options.delete :node_ssl_verify_mode
      self.options.delete :node_verify_api_cert
      self.options.delete :policy_group

      ## Override to use nil by default. It should be create PR
      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME"

      option :bootstrap_converge,
        :long => "--[no-]converge",
        :description => "Bootstrap without Chef-Client Run.(for only update client.rb)",
        :boolean => true,
        :default => true,
        :proc => lambda { |v| Chef::Config[:knife][:bootstrap_converge] = v }

      option :appendix_config,
        :long => "--appendix-config PATH",
        :description => "Append lines to end of client.rb on remote node from file.",
        :proc => lambda { |o| File.read(o) },
        :default => nil

      ## For support policy_document_databag(old style)
      self.options[:policy_name][:description] = "Policy name to use (It'll be set with policy_group=local)"

      def run
        ## Command hook before_bootstrap (After launched Chef-Zero)
        if Chef::Config[:knife][:before_bootstrap]
          ::Knife::Zero::Helper.hook_shell_out!("before_bootstrap", ui, Chef::Config[:knife][:before_bootstrap])
        end

        if @config[:first_boot_attributes_from_file]
          @config[:first_boot_attributes_from_file] = @config[:first_boot_attributes_from_file].merge(build_knifezero_attributes_for_node)
        else
          if @config[:first_boot_attributes]
            @config[:first_boot_attributes] = @config[:first_boot_attributes].merge(build_knifezero_attributes_for_node)
          else
            @config[:first_boot_attributes] = build_knifezero_attributes_for_node
          end
        end
        super
      end

      def knife_ssh
        begin
        ssh = Chef::Knife::BootstrapSsh.new
        ssh.ui = ui
        ssh.name_args = [ server_name, ssh_command ]
        ssh.config = Net::SSH.configuration_for(server_name)
        ssh.config[:ssh_user] = user_name || config[:ssh_user] || Chef::Config[:knife][:ssh_user]
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

      ## For support policy_document_databag(old style)
      def validate_options!
        if policyfile_and_run_list_given?
          ui.error("Policyfile options and --run-list are exclusive")
          exit 1
        end
        true
      end

      def build_knifezero_attributes_for_node
## Return to Pending.
#         ssh_url = String.new("ssh://")
#         ssh_url << config[:ssh_user] || Chef::Config[:knife][:ssh_user]
#         ssh_url << "@"
#         ssh_url << server_name
#         ssh_url << ":"
#         port =  config[:ssh_port] || Chef::Config[:knife][:ssh_port] || 22
#         ssh_url << port.to_s
        attr = Mash.new
        attr[:knife_zero] = {
          host: server_name
#           ssh_url: ssh_url
        }
        attr
      end

    end
  end
end
