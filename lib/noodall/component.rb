module Noodall
  class Component
    include MongoMapper::EmbeddedDocument

    key :_type, String
    key :style, String

    embedded_in :node

    module ClassMethods
      def possible_slots
        Node.possible_slots
      end

      def allowed_positions(*args)
        warn "[DEPRECATION] `allowed_positions` is deprecated. Please use `Noodall::Node.slot` instead."
        allowed_positions = args.reject{|a| !Node.possible_slots.include?(a) }.uniq

        allowed_positions.each do |p|
          Node.send("#{p}_slot_components") << self
        end
      end

      def positions_classes(position)
        Node.send("#{position}_slot_components")
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
