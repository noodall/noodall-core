module Noodall
  module MultiParameterAttributes
    module InstanceMethods
      def attributes=(attrs)
        multi_parameter_attributes = []
        attrs.each do |name, value|
          return if attrs.blank?
          if name.to_s.include?("(")
            multi_parameter_attributes << [ name, value ]
          else
            writer_method = "#{name}="
            if respond_to?(writer_method)
              self.send(writer_method, value)
            else
              self[name.to_s] = value
            end
          end
        end
  
        assign_multiparameter_attributes(multi_parameter_attributes)
      end
  
      def assign_multiparameter_attributes(pairs)
        execute_callstack_for_multiparameter_attributes(
          extract_callstack_for_multiparameter_attributes(pairs)
        )
      end
  
      def execute_callstack_for_multiparameter_attributes(callstack)
        callstack.each do |name, values_with_empty_parameters|
          # in order to allow a date to be set without a year, we must keep the empty values.
          # Otherwise, we wouldn't be able to distinguish it from a date with an empty day.
          values = values_with_empty_parameters.reject(&:blank?)
  
          if values.any?
            key = self.class.keys[name]
            raise ArgumentError, "Unknown key #{name}" if key.nil?
            klass = key.type
  
            value = if Time == klass
              Time.zone.local(*values)
            elsif Date == klass
              begin
                values = values_with_empty_parameters.collect do |v| v.nil? ? 1 : v end
                Date.new(*values)
              rescue ArgumentError => ex # if Date.new raises an exception on an invalid date
                Time.zone.local(*values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
              end
            else
              klass.new(*values)
            end
          else
            value = nil
          end
          writer_method = "#{name}="
          if respond_to?(writer_method)
            self.send(writer_method, value)
          else
            self[name.to_s] = value
          end
        end
      end
  
      def extract_callstack_for_multiparameter_attributes(pairs)
        attributes = { }
  
        for pair in pairs
          multiparameter_name, value = pair
          attribute_name = multiparameter_name.split("(").first
          attributes[attribute_name] = [] unless attributes.include?(attribute_name)
  
          attributes[attribute_name] << [ find_parameter_position(multiparameter_name), value ]
        end
  
        attributes.each { |name, values| attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last } }
      end
  
      def find_parameter_position(multiparameter_name)
        multiparameter_name.scan(/\(([0-9]*).*\)/).first.first
      end
    end
  end
end
