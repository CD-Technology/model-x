module ModelX

  # Base ModelX class. Does nothing more than include {ModelX::Mixin} and define
  # a constructor.
  class Base

    include Mixin

    # Initializes the ModelX class by assigning all specified attributes.
    #
    # @yield [self] Yields the new model if a block is given
    def initialize(attributes = {})
      self.attributes = attributes if attributes.present?
      yield self if block_given?
    end

  end

end