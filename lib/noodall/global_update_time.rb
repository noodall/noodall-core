module Noodall
  module GlobalUpdateTime
    class Stamp
      def self.read
        Rails.cache.read('global_update_time') if defined?(Rails)
      end
  
      def self.update!
        Rails.cache.write('global_update_time', Time.zone.now.utc) if defined?(Rails)
      end
    end
  
    def self.configure(model)
      model.class_eval do
        after_save :global_updated!
        after_destroy :global_updated!
      end
    end
  
    module InstanceMethods
      # Cache the updated time
      def global_updated!
        GlobalUpdateTime::Stamp.update!
      end
    end
  end
end
