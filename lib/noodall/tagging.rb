module Noodall
  module Tagging
    extend ActiveSupport::Concern

    included do
      key :tags, Array, :index => true
    end

    module ClassMethods

      # Tag cloud representing all Node tags and their usage count
      #
      # Returns Array of Tag objects
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

      # Internal: Map used to map_reduce the tag_cloud
      def tag_cloud_map
       "function(){" +
        "this.tags.forEach(" +
        "function(z){" +
        "emit( z , 1 );" +
        "}" +
        ")}"
      end

      # Internal: Reduce used to map_reduce the tag_cloud
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

      # Sets the Node's 'tags'
      #
      # Examples
      #
      #   node = Noodall::Node.find_by_permalink('a-page')
      #   node.tag_list = 'apple, banana, orange'
      #   # => "apple, banana, orange"
      #
      # Returns Array of comma separated tags
      def tag_list=(string)
        self.tags = string.to_s.split(',').map{ |t| t.strip.downcase }.reject(&:blank?).compact.uniq
      end

      # List of 'tags' assigned to the Node
      #
      # Examples
      #
      #   node = Noodall::Node.find_by_permalink('a-page')
      #   node.tag_list
      #   # => "apple, banana, orange"
      #
      # Returns Array of comma separated tags
      def tag_list
        tags.join(', ')
      end

      # All Nodes related to this one by their tags
      #
      # Returns Array of Nodes that are related
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
