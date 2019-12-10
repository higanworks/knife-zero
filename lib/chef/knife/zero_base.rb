require 'chef'
require 'chef/knife/ssh'
require 'chef/knife/bootstrap' unless Chef::Knife.const_defined?(:Bootstrap)

class Chef
  class Knife
    module ZeroBase
      def self.included(includer)
        includer.class_eval do
          deps do
            Chef::Config[:local_mode] = true
            ## deprecated CHEF-18.
            ## TODO: should implement unix domain socket forwarding (~< net-ssh 4.1.0) before will be removed.
            Chef::Config[:listen]     = true
            Chef::Config[:knife_zero] = {}
            Chef::Knife::Ssh.load_deps
          end

          ## Added by Knife-Zero
          option :why_run,
                 short: '-W',
                 long: '--why-run',
                 description: 'Enable whyrun mode on chef-client run at remote node.',
                 boolean: true

          option :remote_chef_zero_port,
                 long: '--remote-chef-zero-port PORT',
                 description: 'Listen port on remote',
                 default: nil,
                 proc: proc { |key| Chef::Config[:remote_chef_zero_port] = key.to_i }

          option :alter_project,
                 long: '--alter-project PROJECT',
                 proc: proc { |u| Chef::Config[:alter_project] = u },
                 description: 'Products used on remote nodes',
                 default: 'chef',
                 in: %w{chef cinc}

          option :node_config_file,
                 long: '--node-config PATH_TO_CONFIG',
                 proc: proc { |u| Chef::Config[:node_config_file] = u },
                 description: 'The configuration file to use on remote node',
                 default: '/etc/chef/client.rb'
        end
      end

      private

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end
    end
  end
end
