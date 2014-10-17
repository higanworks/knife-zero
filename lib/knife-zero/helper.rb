module Knife
  module Zero
    module Helper
      def count_alive_pids(pids)
        alive = 0
        pids.each do |pid|
          begin
            Process.getpgid pid
            alive +=1
          rescue
            next
          end
        end
        alive
      end
    end
  end
end
