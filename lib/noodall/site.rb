module Noodall
  class Site
    class << self

      attr_accessor :map, :permalinks

      def build!
        return false unless map.is_a?(Hash)
        map.each do |permalink, attributes|
          build_node(permalink, attributes)
        end
      end

      def contains?(permalink)
        self.permalinks ||= []
        return false unless map.is_a?(Hash)
        return true if map.keys.include?(permalink)
        map.values.each do |attrubutes|
          extract_permalinks(attrubutes)
        end
        return permalinks.include?(permalink)
      end

      private

      def extract_permalinks(attributes)
        children = attributes['children']
        if children
          self.permalinks = permalinks | children.keys
          children.values.each do |attributes|
            extract_permalinks(attributes)
          end
        end
      end

      def build_node(permalink, attr)
        attributes = attr.dup
        klass_name = attributes.delete('type')
        children = attributes.delete('children')

        node = Noodall::Node.first(:permalink => permalink) || create_node(klass_name, attributes.merge(:permalink => permalink))
        children.each do |permalink, attributes|
          build_node(permalink, attributes.merge(:parent => node))
        end if children
      end

      def create_node(klass_name, attributes)
        if defined?(Factory) && Factory.factories[klass_name.underscore.to_sym]
          Factory(klass_name.underscore, attributes)
        else
          klass_name.constantize.create!(attributes)
        end
      end

    end
  end
end
