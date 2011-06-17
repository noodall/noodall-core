module Noodall
  module Indexer
    extend ActiveSupport::Concern

    included do
      cattr_accessor :indexes
      self.indexes = []
    end

    module ClassMethods
      def ensure_index(*args)
        self.indexes << args
      end

      def create_indexes!
        self.indexes.each do |args|
          puts "Creating index #{args.inspect}"
          collection.create_index(*args)
        end
      end
    end
  end
end

