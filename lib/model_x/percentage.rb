module ModelX

  # Adds percentage attribute accessors to any object. These are attribute accessors with a '_percentage' suffix
  # which simply accept a number multiplied by 100.
  module Percentage
    extend ActiveSupport::Concern

    module ClassMethods

      # Adds percentage attributes for the given attribute. Per specified attribute, the following are added:
      #
      # +:<attribute>_percentage+::
      #   Retrieves or accepts the value of the original times 100.
      #
      # == Usage
      #
      #   class MyObject
      #     include ModelX::Percentage
      #
      #     attr_accessor :my_attribute
      #     percentage :my_attribute
      #   end
      #
      # Now, the following holds true:
      #
      #   object = MyObject.new
      #
      #   object.my_attribute = 0.5
      #   object.my_attribute_percentage # => 50
      #
      #   object.my_attribute_percentage = 10
      #   object.my_attribute # => 0.1
      #
      # Note that an existing attribute reader *must* exist. For the writer to be defined, an existing attribute
      # writer must exist.
      def percentage(*attributes)
        attributes.each do |attribute|

          # An attribute must already exist.
          unless instance_methods.include?(:"#{attribute}") || instance_methods.include?(:read_attribute)
            raise ArgumentError, "cannot add percentage attribute #{attribute} - no existing attribute exists"
          end

          define_writer = instance_methods.include?(:"#{attribute}=") || private_instance_methods.include?(:write_attribute)

          # Create a *_percentage reader and writer.
          class_eval <<-RUBY, __FILE__, __LINE__+1

            def #{attribute}_multiplier
              1 - (#{attribute}.to_f || 0)
            end

            def #{attribute}_increase_multiplier
              1 + (#{attribute}.to_f || 0)
            end

            alias_method  :#{attribute}_decrease_multiplier, :#{attribute}_multiplier

            def #{attribute}_percentage
              @#{attribute}_percentage ||= if #{attribute}.present?
                #{attribute}.to_f * 100
              else
                nil
              end
            end

            def self.human_attribute_name(attribute, options = {})
              if attribute =~ /_percentage$/
                super $`, options
              else
                super
              end
            end

          RUBY

          if define_writer
            validates_numericality_of :"#{attribute}_percentage", :allow_blank => true

            class_eval <<-RUBY, __FILE__, __LINE__+1

              def #{attribute}_percentage=(value)
                if value.present?
                  @#{attribute}_percentage = value
                  self.#{attribute} = value.to_f / 100
                else
                  @#{attribute}_percentage = nil
                  self.#{attribute} = nil
                end
              end

            RUBY
          end

        end
      end

    end

  end

end