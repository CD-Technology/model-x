require 'active_support'
require 'active_model'

module ModelX

  extend ActiveSupport::Autoload

  class AttributeAlreadyDefined < Exception; end
  class AttributeNotFound < RuntimeError; end

  autoload :Base
  autoload :Mixin
  autoload :Attributes
  autoload :Associations
  autoload :Boolean
  autoload :Percentage

end