module ModelX

  # Adds rudimentary 'associations' support to simple models. As there is no real database connection to
  # another object, it is merely simulated by creating two attributes: +<name>+ and +<name>_id+. They work
  # together so that a database association is simulated.
  module Associations
    extend ActiveSupport::Concern

    module ClassMethods

      ######
      # Association definition methods

        # Define a belongs_to association.
        #
        # @param [Symbol|String] association The name of the association.
        # @option options [String] :class_name The class name of the associated object.
        # @option options [#to_s] :foreign_key The foreign key to use.
        def belongs_to(association, options = {})
          class_name = options[:class_name] || association.to_s.camelize
          foreign_key = options[:foreign_key] || "#{association}_id"

          attribute foreign_key

          # Define attribute readers and writers for the ID attribute.
          class_eval <<-RUBY, __FILE__, __LINE__+1

            def #{foreign_key}
              read_attribute(:#{foreign_key}) || @#{association}.try(:id)
            end

            def #{foreign_key}=(value)
              value = nil if value.blank?
              write_attribute :#{foreign_key}, value
              @#{association} = nil
            end

            def #{association}(reload = false)
              id = #{foreign_key}
              if reload
                @#{association} = ::#{class_name}.find_by_id(id) if id
              else
                @#{association} ||= ::#{class_name}.find_by_id(id) if id
              end
            end

            def #{association}=(value)
              value = nil if value.blank?
              @#{association} = value
              write_attribute :#{foreign_key}, nil
            end

          RUBY

        end

        # Defines a has_many association.
        def has_many(association, options = {})
          attribute association

          class_name = options[:class_name] || association.to_s.singularize.camelize
          foreign_key = options[:foreign_key] || "#{association.to_s.singularize}_id"
          ids_attribute = foreign_key.pluralize

          attribute ids_attribute

          # Define attribute readers and writers for the ID attribute.
          class_eval <<-RUBY, __FILE__, __LINE__+1

            def #{ids_attribute}
              read_attribute(:#{ids_attribute}) || read_attribute(:#{association}).try(:id)
            end

            def #{ids_attribute}=(value)
              value = nil if value.blank?
              write_attribute :#{ids_attribute}, value
              @#{association} = nil
            end

            def #{association}(reload = false)
              ids = #{ids_attribute}
              if reload
                @#{association} = ::#{class_name}.where(:id => ids) if ids
              else
                @#{association} ||= ::#{class_name}.where(:id => ids) if ids
              end
            end

            def #{association}=(value)
              value = nil if value.blank?
              @#{association} = value
              write_attribute :#{ids_attribute}, nil
            end

          RUBY

        end


    end

  end

end