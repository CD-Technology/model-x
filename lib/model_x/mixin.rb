module ModelX
  module Mixin
    extend ActiveSupport::Concern

    # Include standard activemodel stuff.
    include ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON
    include ActiveModel::Translation

    included { extend ActiveModel::Callbacks }
    include ActiveModel::Validations::Callbacks

    include ModelX::Attributes
    include ModelX::Associations
    include ModelX::Boolean
    include ModelX::Percentage

    def persisted?() false end
    def to_key() false end

  end
end