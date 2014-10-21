require 'net/ssh/multi/version'

if Net::SSH::Multi::Version::STRING == "1.1.0" || Net::SSH::Multi::Version::STRING == "1.2.0"

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
end
