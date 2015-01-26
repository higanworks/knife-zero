require 'chef/knife/core/bootstrap_context'

class Chef
  class Knife
    module Core
      class BootstrapContext
         class_eval do
           def start_chef_local
             client_path = @chef_config[:chef_client_path] || 'chef-client'
             s = "#{client_path} -j /etc/chef/first-boot.json"
             s << ' -l debug' if @config[:verbosity] and @config[:verbosity] >= 2
             s << " -E #{bootstrap_environment}" if ::Chef::VERSION.to_f != 0.9 # only use the -E option on Chef 0.10+
             s << " -S http://127.0.0.1:#{URI.parse(Chef::Config.chef_server_url).port}"
             s << " -W" if @config[:why_run]
             s
           end
         end
      end
    end
  end
end
