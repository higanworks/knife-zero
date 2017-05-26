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

        self.options.delete :node_ssl_verify_mode
        self.options.delete :node_verify_api_cert

        ## Override to use nil by default. It should be create PR
        option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME"

        ## For support policy_document_databag(old style)
        self.options[:policy_name][:description] = "Policy name to use (F.Y.I: Default policy_group=local)"

        ## Set `local` to default policy_group
        self.options[:policy_group][:description] = "Policy group name to use (--policy-name must also be given). use 'local' "
        self.options[:policy_group][:default] = "local"
      end

      banner "knife zero bootstrap [SSH_USER@]FQDN (options)"

      ## Import from knife bootstrap except exclusions
      self.options = Bootstrap.options.merge(self.options)

      option :bootstrap_converge,
             :long => "--[no-]converge",
             :description => "Bootstrap without Chef-Client Run.(for only update client.rb)",
             :boolean => true,
             :default => true,
             :proc => lambda { |v| Chef::Config[:knife][:bootstrap_converge] = v }

      option :overwrite_node_object,
             :long => "--[no-]overwrite",
             :description => "Overwrite local node object if node already exist. false by default",
             :boolean => true,
             :default => false,
             :proc => lambda { |v| Chef::Config[:knife][:overwrite_node_object] = v }

      option :appendix_config,
             :long => "--appendix-config PATH",
             :description => "Append lines to end of client.rb on remote node from file.",
             :proc => lambda { |o| File.read(o) },
             :default => nil

      def run
        ## Command hook before_bootstrap (After launched Chef-Zero)
        if Chef::Config[:knife][:before_bootstrap]
          ::Knife::Zero::Helper.hook_shell_out!("before_bootstrap", ui, Chef::Config[:knife][:before_bootstrap])
        end

        if @config[:bootstrap_converge]
          unless @config[:overwrite_node_object]
            q = Chef::Search::Query.new
            node_name = resolve_node_name
            result = q.search(:node, "name:#{node_name} OR knife_zero_host:#{node_name}")
            if result.last > 0
              ui.warn(%Q{Node "#{node_name}" already exist. [Found #{result.last} Node(s) in local search.] (You can skip asking with --overwrite option.)})
              if result.last == 1
                ui.confirm(%Q{Overwrite it }, true, false)
              else
                ui.confirm(%Q{Overwrite one of them }, true, false)
              end
            end
          end
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
        ssh.config = Net::SSH.configuration_for(server_name, true)
        ssh.config[:ssh_user] = user_name || config[:ssh_user] || Chef::Config[:knife][:ssh_user]
        ssh.config[:ssh_password] = config[:ssh_password]
        ssh.config[:ssh_port] = config[:ssh_port] || Chef::Config[:knife][:ssh_port]
        ssh.config[:ssh_gateway] = config[:ssh_gateway] || Chef::Config[:knife][:ssh_gateway]
        ssh.config[:forward_agent] = config[:forward_agent] || Chef::Config[:knife][:forward_agent]
        ssh.config[:identity_file] = config[:identity_file] || Chef::Config[:knife][:identity_file] # DEPRECATED
        ssh.config[:ssh_identity_file] = config[:ssh_identity_file] || Chef::Config[:knife][:ssh_identity_file]
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

      def resolve_node_name
        return @config[:chef_node_name] if @config[:chef_node_name]
        @cli_arguments.first.split('@').last
      end
    end
  end
end
