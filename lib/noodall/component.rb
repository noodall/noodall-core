module Noodall
  class Component
    include MongoMapper::EmbeddedDocument

    key :_type, String
    key :style, String

    embedded_in :node

    module ClassMethods

      # Slots this Component can be placed into
      #
      # Examples
      #
      #   Twitter.possible_slots
      #   # => [:large, :small, :carousel]
      #
      # Returns Array of Symbols for each possible slot
      def possible_slots
        Node.possible_slots
      end

      # Deprecated: Set slots into which this Component is allowed to be placed
      def allowed_positions(*args)
        warn "[DEPRECATION] `allowed_positions` is deprecated. Please use `Noodall::Node.slot` instead."
        allowed_positions = args.reject{|a| !Node.possible_slots.include?(a) }.uniq

        allowed_positions.each do |p|
          Node.send("#{p}_slot_components") << self
        end
      end

      # List of Component classes that can placed into the supplied slot type
      #
      # slot - The type of slot
      #
      # Examples
      #
      #   Noodall::Component.positions_classes('small')
      #   # => [Gallery, Quote, Downloads, Twitter, QuickLinks]
      #
      # Returns Array of Component classes
      def positions_classes(position)
        Node.send("#{position}_slot_components")
      end

      # List of Component names that can placed into the supplied slot type
      #
      # slot - The type of slot
      #
      # Examples
      #
      #   Noodall::Component.positions_names('small')
      #   # => ["Gallery", "Quote", "Downloads", "Twitter", "QuickLinks"]
      #
      # Returns Array of Component names
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
