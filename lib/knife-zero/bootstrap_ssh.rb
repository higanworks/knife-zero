require 'chef/knife/ssh'

class Chef
  class Knife
    class BootstrapSsh < Chef::Knife::Ssh
      def configure_session(args = @name_args)
        host, ssh_port = args[0].split(" ")
        @longest = host.length

        Chef::Log.debug("Configration for #{host}")
        session_opts = {}

        ssh_config = Net::SSH.configuration_for(host)

        # Chef::Config[:knife][:ssh_user] is parsed in #configure_user and written to config[:ssh_user]
        user = config[:ssh_user] || ssh_config[:user]
        hostspec = user ? "#{user}@#{host}" : host
        session_opts[:keys] = File.expand_path(config[:identity_file]) if config[:identity_file]
        session_opts[:keys_only] = true if config[:identity_file]
        session_opts[:password] = config[:ssh_password] if config[:ssh_password]
        session_opts[:forward_agent] = config[:forward_agent]
        session_opts[:port] = config[:ssh_port] ||
          ssh_port || # Use cloud port if available
          Chef::Config[:knife][:ssh_port] ||
          ssh_config[:port]
        session_opts[:logger] = Chef::Log.logger if Chef::Log.level == :debug

        if !config[:host_key_verify]
          session_opts[:paranoid] = false
          session_opts[:user_known_hosts_file] = "/dev/null"
        end

        ## use nomal Net::SSH instead of Net::SSH::Multi for simply tcpforward.
        @session ||= Net::SSH.start(host, user, session_opts)
      end


      def ssh_command(command, subsession=nil)
        chef_zero_port = config[:chef_zero_port] ||
                         Chef::Config[:knife][:chef_zero_port] ||
                         8889
        chef_zero_host = config[:chef_zero_host] ||
                         Chef::Config[:knife][:chef_zero_host] ||
                        '127.0.0.1'

        exit_status = 0
        subsession ||= session
        command = fixup_sudo(command)
        command.force_encoding('binary') if command.respond_to?(:force_encoding)

        Chef::Log.debug("Creating tcp-foward channel to #{chef_zero_host}:#{chef_zero_port}")
        session.forward.remote(8889, chef_zero_host, chef_zero_port)
        subsession.open_channel do |ch|
          ch.request_pty
          ch.exec command do |ch, success|
            raise ArgumentError, "Cannot execute #{command}" unless success
            ch.on_data do |ichannel, data|
              ## Patched
              print_data(ichannel.connection.host, data)
              if data =~ /^knife sudo password: /
                print_data(ichannel.connection.host, "\n")
                ichannel.send_data("#{get_password}\n")
              end
            end
            ch.on_request "exit-status" do |ichannel, data|
              exit_status = [exit_status, data.read_long].max
            end
          end
        end
        session.loop
        exit_status
      end
    end
  end
end

