require 'chef/knife'
require 'chef/knife/zero_base'
require 'chef/knife/zero_converge'
require 'chef/application/apply'
require 'knife-zero/bootstrap_ssh'
require 'knife-zero/helper'
require 'shellwords'

class Chef
  class Knife
    class ZeroApply < Chef::Knife::BootstrapSsh
      include Chef::Knife::ZeroBase
      deps do
        Chef::Knife::BootstrapSsh.load_deps
        Chef::Knife::ZeroConverge.load_deps
        require "knife-zero/helper"
      end

      banner "knife zero apply QUERY (options)"

      self.options = Ssh.options.merge(self.options)
      self.options = ZeroConverge.options.merge(self.options)
      self.options[:use_sudo_password] = Bootstrap.options[:use_sudo_password]
      self.options.delete(:override_runlist)

      option :recipe,
        :short        => "-r Recipe String or @filename",
        :long         => "--recipe Recipe String or @filename",
        :description  => "Recipe for execute by chef-apply",
        :default => "",
        :proc => lambda { |o| o.start_with?('@') ? File.read(o[1..-1]).shellescape : (o.to_s).shellescape }

      ## Import from Chef-Apply
      self.options[:minimal_ohai] = Chef::Application::Apply.options[:minimal_ohai]
      self.options[:json_attribs] = Chef::Application::Apply.options[:json_attribs]
      self.options[:json_attribs][:description] = "Load attributes from a JSON file or URL (retrieves from the remote node)"


      def initialize(argv=[])
        super
        self.configure_chef

        @name_args = [@name_args[0], start_chef_apply]
      end

      def start_chef_apply
        if @config[:verbosity] and @config[:verbosity] >= 2
          log_level = 'debug'
        else
          log_level = 'info'
        end

        client_path = @config[:use_sudo] || Chef::Config[:knife][:use_sudo] ? 'sudo ' : ''
        client_path = @config[:chef_client_path] ? "#{client_path}#{@config[:chef_client_path]}" : "#{client_path}chef-apply"
        s = String.new("echo #{@config[:recipe]} | #{client_path}")
        s << " -l #{log_level}"
        s << " -s"
        s << " --minimal-ohai" if @config[:minimal_ohai]
        s << " -j #{@config[:json_attribs]}" if @config[:json_attribs]
        s << " --no-color" unless @config[:color]
        s << " -W" if @config[:why_run]
        Chef::Log.info "Remote command: " + s
        s
      end
    end
  end
end
