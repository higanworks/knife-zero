require 'chef/knife/bootstrap/train_connector'
require 'knife-zero/helper'

class Chef
  class Knife
    class Bootstrap < Knife
      class TrainConnector
        class_eval do
          def connect!
            # Force connection to establish
            connection.wait_until_ready
            if connection.is_a? Train::Transports::SSH::Connection
              connection.instance_variable_get(:@session)
              .forward.remote(
                URI.parse(Chef::Config.chef_server_url).port,
                '127.0.0.1', ::Knife::Zero::Helper.zero_remote_port
              )
            end
            true
          end
        end
      end
    end
  end
end
