require 'open-uri'

module Knife
  module Zero
    module Helper
      def self.zero_remote_port
        return ::Chef::Config[:remote_chef_zero_port] if ::Chef::Config[:remote_chef_zero_port]
        chef_zero_port = ::Chef::Config[:chef_zero_port] ||
                         ::Chef::Config[:knife][:chef_zero_port] ||
                         8889
        chef_zero_port + 10000
      end

      def self.chef_version_available?(version)
        return true if version == 'latest'
        chefgem_metaurl = 'https://rubygems.org/api/v1/versions/chef.json'
        begin
          c_versions = JSON.parse(open(chefgem_metaurl).read).map {|v| v['number']}
          c_versions.include?(version)
        rescue => e
          puts e.inspect
          puts "Some Error occurerd while fetching versions from #{chefgem_metaurl}. Please try again later."
          exit
        end
      end
    end
  end
end
