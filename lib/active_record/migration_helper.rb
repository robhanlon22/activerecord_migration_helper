require 'require_relative'

require_relative 'migration_helper/version'

module ActiveRecord
  module MigrationHelper
    # Public:
    #   Abstracts column ignores.
    #
    #   Example:
    #     class Post < ActiveRecord::Base
    #       extend ActiveRecord::MigrationHelper
    #
    #       dropping :text, :author
    #     end
    def dropping(*column_names)
      singleton_class.class_eval do
        define_method(:columns) do
          column_names_as_symbols = column_names.map(&:to_sym)
          super().reject do |column|
            column_names_as_symbols.include?(column.name.to_sym)
          end
        end
      end
    end

    # Public:
    #   Creates a before_validation callback that assigns the value of one
    #   column to another. Used to replicate data to new columns before
    #   executing a rename.
    #
    #   Options:
    #     :to (REQUIRED):
    #       The new name of the column.
    #
    #     :fail_on_missing_attributes:
    #       Will cause a validation error if either of the attributes
    #       have not been loaded or do not exist. Defaults to false.
    #
    #   Examples:
    #     class Post < ActiveRecord::Base
    #       extend ActiveRecord::MigrationHelper
    #
    #       renaming :text, :to => :body
    #       renaming :author,
    #                :to => :writer,
    #                :fail_on_missing_attributes => true
    #     end
    def renaming(from_column_name, options)
      to_column_name = options[:to]

      unless to_column_name.present?
        raise ArgumentError, 'must supply :to option to ::renaming'
      end

      before_validation do
        if has_attribute?(to_column_name) && has_attribute?(from_column_name)
          send(:"#{to_column_name}=", send(from_column_name))
        elsif options[:fail_on_missing_attributes].present?
          [to_column_name, from_column_name].each do |column_name|
            unless has_attribute?(column_name)
              errors.add(column_name, 'is missing')
            end
          end
        end
      end
    end
  end
end
