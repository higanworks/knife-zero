require 'chef/knife/bootstrap/train_connector'


class Chef
  class Knife
    class Bootstrap < Knife
      class TrainConnector
        class_eval do
          def connect!
            # Force connection to establish
            connection.wait_until_ready
            connection.instance_variable_get(:@session).forward.remote(8889, '127.0.0.1', 18889)
            true
          end
        end
      end
    end
  end
end
