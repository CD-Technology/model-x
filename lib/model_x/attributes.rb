module ModelX

  # Provides attribute DSL methods.
  #
  # == Defaults && types
  #
  # For each attribute, you can set a default which is returned if the virtual attribute would otherwise
  # be +nil+.
  #
  # You may also specify a 'type' for the virtual attribute. This does nothing more than evaluate the line
  # <tt>&lt;type&gt; :&lt;attribute&gt;</tt> into the model, e.g.
  #
  #   attribute :has_price, :type => :boolean
  #
  # is equivalent to
  #
  #   attribute :has_price
  #   boolean :has_price
  module Attributes
    extend ActiveSupport::Concern

    # Attributes hash. Builds an attributes hash from current instance variables.
    def attributes
      @attributes ||= self.class.attributes.inject({}) do |attrs, name|
        next attrs if name == :'attributes'
        attrs[name.to_sym] = send(name)
        attrs
      end
    end

    # Assigns the attributes hash by setting all given values through attribute writers.
    #
    # @raise [AttributeNotFound] if a certain attribute is not found.
    def attributes=(values)
      assign_attributes values
    end

    # Assigns the model's attributes with the values from the given hash.
    #
    # @option options [Symbol] :missing (:raise)
    #   Specify the behavior for missing attributes. +:raise+ raises an exception, +:ignore+
    #   ignores the missing attributes.
    def assign_attributes(values, options = {})
      raise ArgumentError, "hash required" unless values.is_a?(Hash)

      options = options.symbolize_keys
      options.assert_valid_keys :missing

      values.each do |key, value|
        if respond_to?(:"#{key}=")
          send :"#{key}=", value
        elsif options[:missing] == :raise
          raise AttributeNotFound, "attribute :#{key} not found"
        end
      end
      self
    end

    # Reads an attribute value.
    def read_attribute(attribute)
      instance_variable_get("@#{attribute}")
    end
    protected :read_attribute

    # Reads an attribute value.
    def [](attribute)
      read_attribute attribute
    end

    # Writes an attribute value
    def write_attribute(attribute, value)
      @attributes = nil
      instance_variable_set "@#{attribute}", value
    end
    protected :write_attribute

    module ClassMethods

      # @!attribute [r] attributes
      # @return [Array] An array of defined attribute names.
      def attributes
        @attributes ||= []
      end

      # @!method attribute(*attributes, options = {})
      # DSL method to define attributes.
      #
      # @option options :default
      #   A default value for the attribute.
      # @option options [Symbol] :type
      #   A type for the attribute.
      def attribute(*attributes)
        options = attributes.extract_options!

        @_model_x_defaults ||= {}
        @_model_x_types ||= {}

        attributes.each do |attribute|
          attribute = attribute.to_sym

          if instance_methods.include?(attribute)
            raise AttributeAlreadyDefined, "attribute :#{attribute} is already defined on #{self.name}"
          end
          self.attributes << attribute

          @_model_x_defaults[attribute] = options[:default] if options.key?(:default)
          @_model_x_types[attribute] = options[:type]

          class_eval <<-RUBY, __FILE__, __LINE__+1

            def #{attribute}
              value = read_attribute(:#{attribute})
              value = self.class.send(:_model_x_default, :#{attribute}) if value.nil?
              value
            end

            def #{attribute}=(value)
              write_attribute :#{attribute}, value
            end

          RUBY

          if options[:type]
            class_eval <<-RUBY, __FILE__, __LINE__+1
              #{options[:type]} :#{attribute}
            RUBY
          end

        end
      end

      private

        def _model_x_default(attribute)
          if @_model_x_defaults && @_model_x_defaults.key?(attribute)
            @_model_x_defaults[attribute]
          elsif superclass.private_methods.include?(:_model_x_default)
            superclass.send :_model_x_default, attribute
          end
        end

        def _model_x_convert(attribute, value)
          if @_model_x_types[attribute]
            if ModelX.const_defined?(@_model_x_types[attribute].to_s.camelize)
              ModelX.const_get(@_model_x_types[attribute].to_s.camelize).convert(value)
            else
              raise "no converter found for type #{@_model_x_types[attribute]}"
            end
          else
            value
          end
        end

    end

  end

end