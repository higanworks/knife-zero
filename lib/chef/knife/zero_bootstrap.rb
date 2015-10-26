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
      self.options = Bootstrap.options.merge(self.options)
      self.options.delete :node_ssl_verify_mode
      self.options.delete :node_verify_api_cert

      ## Override to use nil by default
      option :ssh_user,
        :short => "-x USERNAME",
        :long => "--ssh-user USERNAME"

      option :bootstrap_converge,
        :long => "--[no-]converge",
        :description => "Bootstrap without Chef-Client Run.(for only update client.rb)",
        :boolean => true,
        :default => true,
        :proc => lambda { |v| Chef::Config[:knife][:bootstrap_converge] = v }

      ## monkey for #3900(included 12.5.2) >>
      if Gem::Version.new(Chef::VERSION) < Gem::Version.new('12.5.2')
        unless options.has_key?(:first_boot_attributes_from_file)
          option :first_boot_attributes_from_file,
            :long => "--json-attribute-file FILE",
            :description => "A JSON file to be used to the first run of chef-client",
            :proc => lambda { |o| Chef::JSONCompat.parse(File.read(o)) },
            :default => nil

          def first_boot_attributes
            @config[:first_boot_attributes] || @config[:first_boot_attributes_from_file] || {}
          end

          def render_template
            @config[:first_boot_attributes] = first_boot_attributes
            template_file = find_template
            template = IO.read(template_file).chomp
            Erubis::Eruby.new(template).evaluate(bootstrap_context)
          end

          ## monkey for #3900(included 12.5.2) <<
        end
      end

      def run
      ## monkey for #3900(included 12.5.2) >>
        if Gem::Version.new(Chef::VERSION) < Gem::Version.new('12.5.2')
          if @config[:first_boot_attributes] # Check for edge master
            if @config[:first_boot_attributes].any? && @config[:first_boot_attributes_from_file]
              raise "You cannot pass both --json-attributes and --json-attribute-file."
            end
          end
        end
      ## monkey for #3900(included 12.5.2) <<

        if @config[:first_boot_attributes_from_file]
          @config[:first_boot_attributes_from_file] = @config[:first_boot_attributes_from_file].merge(build_knifezero_attributes_for_node)
        else
          @config[:first_boot_attributes] = build_knifezero_attributes_for_node
        end
        super
      end

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
