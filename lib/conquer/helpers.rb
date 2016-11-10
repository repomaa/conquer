require 'celluloid/notifications'
module Conquer
  module Helpers
    module_function

    def publish(*args)
      Celluloid::Notifications.publish(*args)
    end
  end
end
