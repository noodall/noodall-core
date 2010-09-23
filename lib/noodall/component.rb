module Noodall
  class Component
    include MongoMapper::EmbeddedDocument
    
    key :_type, String
    key :style, String
  
    embedded_in :node
  
    module ClassMethods
      def possible_slots
        Noodall::Node.possible_slots
      end

      def allowed_positions(*args)
        @allowed_positions = args.reject{|a| !Node.possible_slots.include?(a) }.uniq
      end
  
      def positions
        @allowed_positions || []
      end
  
      def positions_classes(position)
        classes = []
        ObjectSpace.each_object(Class) do |c|
          next unless c.ancestors.include?(Component) and (c != Component) and c.positions.include?(position)
          classes << c
        end
        classes
      end
  
      def positions_names(position)
        positions_classes(position).collect{|c| c.name.titleize }
      end
  
      # Allow us to set the component to nil if we get a blank
      def to_mongo(value)
        return nil if value.blank?
        super
      end
  
    end
    extend ClassMethods
  end  
end
