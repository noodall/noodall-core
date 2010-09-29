module Noodall
  module Indexer
    module ClassMethods
      def ensure_index(spec, options={})
        #collection.create_index(spec, options)
        # TODO: something clever here as runtime indexing is bad
      end
    end
  end
end

