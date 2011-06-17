module Noodall
  module Tagging
    extend ActiveSupport::Concern

    included do
      key :tags, Array, :index => true
    end

    module ClassMethods
      def tag_cloud(options = {})
        return [] if self.count == 0 # Don't bother if there is nothing in this collection
        query = query(options.reverse_merge(
          :order => 'value DESC'
        ))
        tags_map = collection.map_reduce(tag_cloud_map, tag_cloud_reduce, {:query => query.criteria.to_hash, :out => "#{self.collection_name}_tags" })
        if tags_map.count > 0
          tags = tags_map.find({}, query.options.to_hash ).to_a.collect{ |hash| Tag.new(hash['_id'], hash['value']) }
          tags
        else
          []
        end
      end

      def tag_cloud_map
       "function(){" +
        "this.tags.forEach(" +
        "function(z){" +
        "emit( z , 1 );" +
        "}" +
        ")}"
      end

      def tag_cloud_reduce
        "function( key , values ){" +
        "var total = 0;" +
        "for ( var i=0; i<values.length; i++ ){" +
        "total += values[i];" +
        "}" +
        "return total;" +
        "}"
      end
    end

    module InstanceMethods
      def tag_list=(string)
        self.tags = string.to_s.split(',').map{ |t| t.strip.downcase }.reject(&:blank?).compact.uniq
      end

      def tag_list
        tags.join(', ')
      end

      def related(options ={})
        self.class.all(options.merge({:_id => {'$ne' => self._id}, :tags => /(#{self.tags.join('|')})/i}))
      end
    end

    class Tag
      attr_reader :name, :count

      def initialize(name, count)
        @name = name
        @count = count.to_i
      end
    end
  end
end
