module ModelX

  # Adds boolean attribute accessors to any object, allowing boolean-ish values to be set as well.
  #
  # == Usage
  #
  #   class MyObject
  #     include ModelX::Boolean
  #
  #     attr_accessor :my_attribute
  #     boolean :my_attribute
  #   end
  #
  # Now, the following can be used:
  #
  #   object = MyObject.new
  #   object.my_attribute = false
  #   object.my_attribute? # => false
  #
  #   object.my_attribute = '0'
  #   object.my_attribute? # => false
  #   object.my_attribute = '1'
  #   object.my_attribute? # => true
  #   object.my_attribute = 'false'
  #   object.my_attribute? # => false
  #
  # Note that an existing attribute writer *must* exist.
  #
  # The values '0', 0, 'off', 'no' and 'false', and all values that Ruby considers false are deemed to be false.
  # All other values are true.
  module Boolean
    extend ActiveSupport::Concern

    module ClassMethods

      def boolean(*attributes)
        attributes.each do |attribute|

          # An attribute must already exist.
          unless instance_methods.include?(:"#{attribute}=")
            raise ArgumentError, "cannot add boolean attribute #{attribute} - no existing attribute exists"
          end

          # Override the writer and add a ? version.
          class_eval <<-RUBY, __FILE__, __LINE__+1

            def #{attribute}_with_model_x_boolean=(value)
              self.#{attribute}_without_model_x_boolean = ModelX::Boolean.convert(value)
            end
            alias_method_chain :#{attribute}=, :model_x_boolean
            alias_method :#{attribute}?, :#{attribute}

          RUBY

        end
      end

    end

    # Converts a boolean attribute. This is used mostly for toggle buttons that
    # enable or disable an input section.
    def self.convert(value)
      value.present? && value != '0' && value != 0 && value != 'off' && value != 'no' && value != 'false'
    end

  end

end