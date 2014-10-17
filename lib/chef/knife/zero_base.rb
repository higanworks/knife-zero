require 'chef'

class Chef
  class Knife
    module ZeroBase
      def self.included(includer)
        includer.class_eval do
          deps do
            Chef::Config[:local_mode] = true
            require 'knife-zero/core/bootstrap_context'
            require 'chef/json_compat'
            require 'tempfile'
            require 'highline'
            require 'net/ssh'
            Chef::Knife::Ssh.load_deps
          end

          option :ssh_user,
            :short => "-x USERNAME",
            :long => "--ssh-user USERNAME",
            :description => "The ssh username",
            :default => "root"

          option :ssh_password,
            :short => "-P PASSWORD",
            :long => "--ssh-password PASSWORD",
            :description => "The ssh password"

          option :identity_file,
            :short => "-i IDENTITY_FILE",
            :long => "--identity-file IDENTITY_FILE",
            :description => "The SSH identity file used for authentication"

          option :ssh_port,
            :short => "-p PORT",
            :long => "--ssh-port PORT",
            :description => "The ssh port",
            :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

          option :ssh_gateway,
            :short => "-G GATEWAY",
            :long => "--ssh-gateway GATEWAY",
            :description => "The ssh gateway",
            :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

          option :forward_agent,
            :short => "-A",
            :long => "--forward-agent",
            :description => "Enable SSH agent forwarding",
            :boolean => true

          option :host_key_verify,
            :long => "--[no-]host-key-verify",
            :description => "Verify host key, enabled by default.",
            :boolean => true,
            :default => true

          option :why_run,
            :short        => '-W',
            :long         => '--why-run',
            :description  => 'Enable whyrun mode on chef-client run at remote node.',
            :boolean      => true

        end
      end

      def knife_ssh
        ssh = Chef::Knife::BootstrapSsh.new
        ssh.ui = ui
        ssh.name_args = [ server_name, ssh_command ] unless ssh.name_args.empty?
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

      private

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end
    end
  end
end
