require 'net/ssh/multi/version'

## 1.3.0~ includes this patch.
if Gem::Version.new(Net::SSH::Multi::Version::STRING) < Gem::Version.new("1.3.0.rc1")
  require 'net/ssh/multi'

  module Net::SSH::Multi
    class PendingConnection
      class ForwardRecording
        def initialize
          @recordings = []
        end

        def remote(port, host, remote_port, remote_host="127.0.0.1")
          @recordings << [:remote, port, host, remote_port, remote_host]
        end

        def replay_on(session)
          forward = session.forward
          @recordings.each {|args| forward.send *args}
        end
      end

      def forward
        forward = ForwardRecording.new
        @recordings << forward
        forward
      end
    end
  end

  # https://github.com/net-ssh/net-ssh-multi/pull/9
  require 'net/ssh/multi/server'
  module Net::SSH::Multi
    class Server
      class_eval do
        def initialize(master, host, options={})
          @master = master
          @options = options.dup

          ## Patched line here
          @user, @host, port = host.match(/^(?:([^;,:=]+)@|)\[?(.*?)\]?(?::(\d+)|)$/)[1,3]

          user_opt, port_opt = @options.delete(:user), @options.delete(:port)

          @user = @user || user_opt || master.default_user
          port ||= port_opt

          @options[:port] = port.to_i if port

          @gateway = @options.delete(:via)
          @failed = false
        end
      end
    end
  end
end
