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

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node"

      option :prerelease,
        :long => "--prerelease",
        :description => "Install the pre-release chef gems"

      option :bootstrap_version,
        :long => "--bootstrap-version VERSION",
        :description => "The version of Chef to install",
        :proc => lambda { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :bootstrap_proxy,
        :long => "--bootstrap-proxy PROXY_URL",
        :description => "The proxy server for the node being bootstrapped",
        :proc => Proc.new { |p| Chef::Config[:knife][:bootstrap_proxy] = p }

      option :bootstrap_no_proxy,
        :long => "--bootstrap-no-proxy [NO_PROXY_URL|NO_PROXY_IP]",
        :description => "Do not proxy locations for the node being bootstrapped; this option is used internally by Opscode",
        :proc => Proc.new { |np| Chef::Config[:knife][:bootstrap_no_proxy] = np }

      ## Patched
      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template",
        :default => "chef-full-localmode"

      option :use_sudo,
        :long => "--sudo",
        :description => "Execute the bootstrap via sudo",
        :boolean => true

      option :use_sudo_password,
        :long => "--use-sudo-password",
        :description => "Execute the bootstrap via sudo with password",
        :boolean => false

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :default => false

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :first_boot_attributes,
        :short => "-j JSON_ATTRIBS",
        :long => "--json-attributes",
        :description => "A JSON string to be added to the first run of chef-client",
        :proc => lambda { |o| Chef::JSONCompat.parse(o) },
        :default => {}

      option :hint,
        :long => "--hint HINT_NAME[=HINT_FILE]",
        :description => "Specify Ohai Hint to be set on the bootstrap target.  Use multiple --hint options to specify multiple hints.",
        :proc => Proc.new { |h|
          Chef::Config[:knife][:hints] ||= Hash.new
          name, path = h.split("=")
          Chef::Config[:knife][:hints][name] = path ? Chef::JSONCompat.parse(::File.read(path)) : Hash.new  }

      option :secret,
        :short => "-s SECRET",
        :long  => "--secret ",
        :description => "The secret key to use to encrypt data bag item values",
        :proc => Proc.new { |s| Chef::Config[:knife][:secret] = s }

      option :secret_file,
        :long => "--secret-file SECRET_FILE",
        :description => "A file containing the secret key to use to encrypt data bag item values",
        :proc => Proc.new { |sf| Chef::Config[:knife][:secret_file] = sf }

      option :bootstrap_url,
        :long        => "--bootstrap-url URL",
        :description => "URL to a custom installation script",
        :proc        => Proc.new { |u| Chef::Config[:knife][:bootstrap_url] = u }

      option :bootstrap_install_command,
        :long        => "--bootstrap-install-command COMMANDS",
        :description => "Custom command to install chef-client",
        :proc        => Proc.new { |ic| Chef::Config[:knife][:bootstrap_install_command] = ic }

      option :bootstrap_wget_options,
        :long        => "--bootstrap-wget-options OPTIONS",
        :description => "Add options to wget when installing chef-client",
        :proc        => Proc.new { |wo| Chef::Config[:knife][:bootstrap_wget_options] = wo }

      option :bootstrap_curl_options,
        :long        => "--bootstrap-curl-options OPTIONS",
        :description => "Add options to curl when install chef-client",
        :proc        => Proc.new { |co| Chef::Config[:knife][:bootstrap_curl_options] = co }

      def knife_ssh
        ssh = Chef::Knife::BootstrapSsh.new
        ssh.ui = ui
        ssh.name_args = [ server_name, ssh_command ]
        ssh.config[:ssh_user] = Chef::Config[:knife][:ssh_user] || config[:ssh_user]
        ssh.config[:ssh_password] = config[:ssh_password]
        ssh.config[:ssh_port] = Chef::Config[:knife][:ssh_port] || config[:ssh_port]
        ssh.config[:ssh_gateway] = Chef::Config[:knife][:ssh_gateway] || config[:ssh_gateway]
        ssh.config[:forward_agent] = Chef::Config[:knife][:forward_agent] || config[:forward_agent]
        ssh.config[:identity_file] = Chef::Config[:knife][:identity_file] || config[:identity_file]
        ssh.config[:manual] = true
        ssh.config[:host_key_verify] = Chef::Config[:knife][:host_key_verify] || config[:host_key_verify]
        ssh.config[:on_error] = :raise
        ssh
      end
    end
  end
end
