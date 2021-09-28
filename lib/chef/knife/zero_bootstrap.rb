require 'chef/knife'
require 'chef/knife/zero_base'

class Chef
  class Knife
    class ZeroBootstrap < Chef::Knife::Bootstrap
      include Chef::Knife::ZeroBase
      deps do
        require 'erubis' unless defined?(Erubis)

        require 'chef/knife/bootstrap/chef_vault_handler'
        require 'chef/knife/bootstrap/client_builder'
        require 'chef/knife/bootstrap/train_connector'
        require 'knife-zero/core/bootstrap_context'
        require 'knife-zero/devpatch/train_connector'
        require 'knife-zero/helper'

        self.options.delete :node_ssl_verify_mode
        self.options.delete :node_verify_api_cert
      end

      banner 'knife zero bootstrap [SSH_USER@]FQDN (options)'

      ## Import from knife bootstrap except exclusions
      self.options = Bootstrap.options.merge(self.options)

      option :bootstrap_converge,
             long: '--[no-]converge',
             description: 'Bootstrap without Chef-Client Run.(for only update client.rb)',
             boolean: true,
             default: true,
             proc: lambda { |v| Chef::Config[:knife][:bootstrap_converge] = v }

      option :overwrite_node_object,
             long: '--[no-]overwrite',
             description: 'Overwrite local node object if node already exist. false by default',
             boolean: true,
             default: false,
             proc: lambda { |v| Chef::Config[:knife][:overwrite_node_object] = v }

      option :appendix_config,
             long: '--appendix-config PATH',
             description: 'Append lines to end of client.rb on remote node from file.',
             proc: lambda { |o| File.read(o) },
             default: nil

      def run # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
        ## Command hook before_bootstrap (After launched Chef-Zero)
        if Chef::Config[:knife][:before_bootstrap]
          ::Knife::Zero::Helper.hook_shell_out!(
            'before_bootstrap',
            ui,
            Chef::Config[:knife][:before_bootstrap]
          )
        end

        case @config[:alter_project]
        when 'cinc'
          @config[:bootstrap_url] = 'https://omnitruck.cinc.sh/install.sh'
        end

        if @config[:bootstrap_converge]
          unless @config[:overwrite_node_object]
            q = Chef::Search::Query.new
            node_name = resolve_node_name
            result = q.search(:node, "name:#{node_name} OR knife_zero_host:#{node_name}")
            if result.last.positive?
              ui.warn(%{Node "#{node_name}" already exist. [Found #{result.last} Node(s) in local search.] (You can skip asking with --overwrite option.)})
              if result.last == 1
                ui.confirm(%{Overwrite it }, true, false)
              else
                ui.confirm(%{Overwrite one of them }, true, false)
              end
            end
          end
        end

        if @config[:first_boot_attributes_from_file]
          @config[:first_boot_attributes_from_file] = @config[:first_boot_attributes_from_file].merge(build_knifezero_attributes_for_node)
        else
          @config[:first_boot_attributes] = if @config[:first_boot_attributes]
                                              @config[:first_boot_attributes].merge(build_knifezero_attributes_for_node)
                                            else
                                              @config[:first_boot_attributes] = build_knifezero_attributes_for_node
                                            end
        end

        File.open(client_builder.client_path, 'w') do |f|
          f.puts OpenSSL::PKey::RSA.new(2048).to_s
        end
        super
      end

      ## For support policy_document_databag(old style)
      def validate_options!
        if policyfile_and_run_list_given?
          ui.error('Policyfile options and --run-list are exclusive')
          exit 1
        end
        true
      end

      def build_knifezero_attributes_for_node
        ## Return to Pending.
        # ssh_url = String.new("ssh://")
        # ssh_url << config[:ssh_user] || Chef::Config[:knife][:ssh_user]
        # ssh_url << "@"
        # ssh_url << server_name
        # ssh_url << ":"
        # port =  config[:ssh_port] || Chef::Config[:knife][:ssh_port] || 22
        # ssh_url << port.to_s
        attr = Mash.new
        attr[:knife_zero] = {
          host: server_name
          # ssh_url: ssh_url
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
