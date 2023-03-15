require 'chef/knife'
require 'chef/knife/zero_base'
require 'chef/application/client'
require 'chef/config_fetcher'
require 'knife-zero/bootstrap_ssh'
require 'knife-zero/helper'

class Chef
  class Knife
    class ZeroConverge < Chef::Knife::BootstrapSsh
      include Chef::Knife::ZeroBase
      deps do
        require 'chef/run_list/run_list_item'
        Chef::Knife::BootstrapSsh.load_deps
        require 'knife-zero/helper'
      end

      banner 'knife zero converge QUERY (options)'

      self.options = Ssh.options.merge(self.options)
      self.options[:use_sudo_password] = Bootstrap.options[:use_sudo_password]

      # fatal by default Ref: https://github.com/chef/chef/pull/6781
      if self.options[:duplicated_fqdns]
        self.options[:duplicated_fqdns][:description] = 'Behavior if FQDNs are duplicated, fatal by default'
        self.options[:duplicated_fqdns][:default] = :fatal
      end

      ## Import Features from chef-client
      self.options[:json_attribs] = Chef::Application::Client.options[:json_attribs]

      ### > 12.5.1
      self.options[:named_run_list] = Chef::Application::Client.options[:named_run_list]

      if ::Knife::Zero::Helper.required_chef_version?('12.8.1')
        self.options[:skip_cookbook_sync] = Chef::Application::Client.options[:skip_cookbook_sync]
      end

      option :splay,
             long: '--splay SECONDS',
             description: 'The splay time for running at intervals, in seconds',
             proc: lambda { |s| s.to_i }

      option :use_sudo,
             long: '--[no-]sudo',
             description: 'Execute the chef-client via sudo (true by default)',
             boolean: true,
             default: true,
             proc: lambda { |v| Chef::Config[:knife][:use_sudo] = v }

      option :override_runlist,
             short: '-o RunlistItem,RunlistItem...',
             long: '--override-runlist RunlistItem,RunlistItem...',
             description: 'Replace current run list with specified items for a single run. It skips save node.json on local',
             default: nil,
             proc: lambda { |o| o.to_s }

      option :client_version,
             long: '--client-version [latest|VERSION]',
             description: 'Up or downgrade omnibus chef-client before converge.',
             default: nil,
             proc: lambda { |o|
               if ::Knife::Zero::Helper.chef_version_available?(o)
                 o.to_s
               else
                 ui.error "Client version #{o} is not found."
                 exit 1
               end
             }

      # import from LicenseAcceptance:CLIFlags:MixlibCLI
      option :chef_license,
             long: '--chef-license ACCEPTANCE',
             description: %{Accept the license for this product and any contained products ('accept', 'accept-no-persist', or 'accept-silent')},
             required: false

      # Common connectivity options for compatibility
      option :connection_user,
             short: '-U USERNAME',
             long: '--connection-user USERNAME',
             description: 'Authenticate to the target host with this user account. (same as --ssh-user)',
             proc: lambda { |v| Chef::Config[:knife][:ssh_user] = v }

      option :connection_password,
             long: '--connection-password PASSWORD',
             description: 'Authenticate to the target host with this password. (same as --ssh-password)',
             proc: lambda { |v| Chef::Config[:knife][:ssh_password_ng] = v }

      option :connection_port,
             long: '--connection-port PORT',
             description: 'The port on the target node to connect to. (same as --ssh-port)',
             proc: lambda { |v| Chef::Config[:knife][:ssh_port] = v }

      def initialize(argv = [])
        super
        self.configure_chef

        ## Command hook before_converge (Before launched Chef-Zero)
        if Chef::Config[:knife][:before_converge]
          ::Knife::Zero::Helper.hook_shell_out!('before_converge', ui, Chef::Config[:knife][:before_converge])
        end

        if @config[:json_attribs]
          @config[:chef_client_json] = fetch_json_from_url
        end

        validate_options!

        @name_args = [@name_args[0], start_chef_client]
      end

      def start_chef_client # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
        client_path = @config[:use_sudo] || Chef::Config[:knife][:use_sudo] ? 'sudo ' : ''
        client_path = @config[:chef_client_path] ? "#{client_path}#{@config[:chef_client_path]}" : "#{client_path}#{ChefUtils::Dist::Infra::CLIENT}"
        s = String.new(client_path)
        s << ' -l debug' if @config[:verbosity] && @config[:verbosity] >= 2
        s << " -S http://127.0.0.1:#{::Knife::Zero::Helper.zero_remote_port}"
        s << " -o #{@config[:override_runlist]}" if @config[:override_runlist]
        s << ' -j /etc/' + ChefUtils::Dist::Infra::DIR_SUFFIX + '/chef_client_json.json' if @config[:json_attribs]
        s << " --splay #{@config[:splay]}" if @config[:splay]
        s << " -n #{@config[:named_run_list]}" if @config[:named_run_list]
        s << " --config #{@config[:node_config_file]}"
        s << ' --skip-cookbook-sync' if @config[:skip_cookbook_sync]
        s << ' --no-color' unless @config[:color]
        s << " -E #{@config[:environment]}" if @config[:environment]
        s << " --chef-license #{@config[:chef_license]}" if @config[:chef_license]
        s << ' -W' if @config[:why_run]
        Chef::Log.info 'Remote command: ' + s
        s
      end

      ## For support policy_document_databag(old style)
      def validate_options!
        if override_and_named_given?
          ui.error('--override_runlist and --named_run_list are exclusive')
          exit 1
        end
        if json_attribs_without_override_given?
          ui.error(
            '--json-attributes must be used with --override-runlist ' \
            'or passed json should includes key `run-list` ' \
            'to avoid unexpected updating local node object.'
          )
          exit 1
        end
        true
      end

      # True if policy_name and run_list are both given
      def override_and_named_given?
        override_runlist_given? && named_run_list_given?
      end

      def override_runlist_given?
        !config[:override_runlist].nil? && !config[:override_runlist].empty? || @config[:chef_client_json]&.key?('run_list')
      end

      def named_run_list_given?
        !config[:named_run_list].nil? && !config[:named_run_list].empty?
      end

      def json_attribs_without_override_given?
        if json_attribs_given?
          return true unless override_runlist_given?
        else
          false
        end
        false
      end

      def json_attribs_given?
        !config[:json_attribs].nil? && !config[:json_attribs].empty?
      end

      def fetch_json_from_url
        config_fetcher = Chef::ConfigFetcher.new(@config[:json_attribs])
        config_fetcher.fetch_json
      end
    end
  end
end
