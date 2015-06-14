require 'chef/knife/core/bootstrap_context'
require "knife-zero/helper"

class Chef
  class Knife
    module Core
      class BootstrapContext
         class_eval do
           alias :orig_validation_key validation_key
           def validation_key
             if @chef_config[:knife_zero]
               OpenSSL::PKey::RSA.new(2048).to_s
             else
               orig_validation_key
             end
           end

           alias :orig_start_chef start_chef
           def start_chef
             if @chef_config[:knife_zero]
               unless @config[:without_chef_run]
               client_path = @chef_config[:chef_client_path] || 'chef-client'
               s = "#{client_path} -j /etc/chef/first-boot.json"
               s << ' -l debug' if @config[:verbosity] and @config[:verbosity] >= 2
               s << " -E #{bootstrap_environment}" if ::Chef::VERSION.to_f != 0.9 # only use the -E option on Chef 0.10+
               s << " -S http://127.0.0.1:#{::Knife::Zero::Helper.zero_remote_port}"
               s << " -W" if @config[:why_run]
               s
               else
                 "echo Execution of Chef-Client has been canceled due to --without-chef-run."
               end
             else
               orig_start_chef
             end
           end
         end
      end
    end
  end
end
