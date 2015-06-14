require 'chef'

class Chef
  class Knife
    module ZeroBase
      def self.included(includer)
        includer.class_eval do
          deps do
            Chef::Config[:local_mode] = true
            Chef::Config[:knife_zero] = Hash.new
            Chef::Knife::Ssh.load_deps
          end

          ## Added by Knife-Zero
          option :why_run,
            :short        => '-W',
            :long         => '--why-run',
            :description  => 'Enable whyrun mode on chef-client run at remote node.',
            :boolean      => true

          option :remote_chef_zero_port,
            :long => "--remote-chef-zero-port PORT",
            :description => "Listen port on remote",
            :default => nil,
            :proc => Proc.new { |key| Chef::Config[:remote_chef_zero_port] = key.to_i }

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
