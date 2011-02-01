module Noodall
  module Indexer
    def self.configure(model)
      model.class_eval do
        cattr_accessor :indexes
      end
      model.indexes = []
    end
    module ClassMethods
      def ensure_index(*args)
        indexes << args
      end

      def create_indexes!
        indexes.each do |args|
          puts "Creating index #{args.inspect}"
          collection.create_index(*args)
        end
      end
    end
  end
end

