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

## monkey patch for ssh keepalive
# Ref: http://qiita.com/kackytw/items/49e2d10512b197089502
require 'net/ssh/multi/server'
module Net::SSH::Multi
  class Server
    class_eval do
      require 'net/ssh/connection/keepalive'
      def new_session #:nodoc:
        session = if gateway
          gateway.ssh(host, user, options)
        else
          Net::SSH.start(host, user, options)
        end

        ## >> Patch
        @keepalive = Net::SSH::Connection::Keepalive.new(session)
        ## << Patch

        session[:server] = self
        session
      rescue ::Timeout::Error => error
        raise Net::SSH::ConnectionTimeout.new("#{error.message} for #{host}")
      rescue Net::SSH::AuthenticationFailed => error
        raise Net::SSH::AuthenticationFailed.new("#{error.message}@#{host}")
      end

      ## >> Patch
      def keepalive_if_needed(readers, writers)
        listeners = session.listeners.keys
        readers = readers || []
        writers = writers || []
        @keepalive.send_as_needed(!(listeners & readers).empty? || !(listeners & writers).empty?)
      end
      ## << Patch
    end
  end
end

require 'net/ssh/multi/session'
module Net::SSH::Multi
  class Session
    class_eval do
      def process(wait=nil, &block)
        realize_pending_connections!
        wait = @connect_threads.any? ? 0 : wait

        return false unless preprocess(&block)

        readers = server_list.map { |s| s.readers }.flatten
        writers = server_list.map { |s| s.writers }.flatten

        readers, writers, = IO.select(readers, writers, nil, wait)

        ## >> Patch
        server_list.each { |server| server.keepalive_if_needed(readers, writers) }
        ## << Patch

        if readers
          return postprocess(readers, writers)
        else
          return true
        end
      end
    end
  end
end
