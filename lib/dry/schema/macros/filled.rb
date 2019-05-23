# frozen_string_literal: true

require 'dry/schema/primitive_inferrer'
require 'dry/schema/macros/value'

module Dry
  module Schema
    module Macros
      # Macro used to prepend `:filled?` predicate
      #
      # @api private
      class Filled < Value
        # @!attribute [r] primitive_inferrer
        #   PrimitiveInferrer used to get a list of primitive classes from configured type
        #   @return [PrimitiveInferrer]
        #   @api private
        option :primitive_inferrer, default: proc { PrimitiveInferrer.new }

        # @api private
        def call(*predicates, **opts, &block)
          if predicates.include?(:empty?)
            raise ::Dry::Schema::InvalidSchemaError, 'Using filled with empty? predicate is invalid'
          end

          if predicates.include?(:filled?)
            raise ::Dry::Schema::InvalidSchemaError, 'Using filled with filled? is redundant'
          end

          if opts[:type_spec]
            if filter?
              value(*predicates, **opts, &block)
            else
              value(predicates[0], :filled?, *predicates[1..predicates.size - 1], **opts, &block)
            end
          else
            value(:filled?, *predicates, **opts, &block)
          end
        end

        # @api private
        def filter?
          !primitives.include?(NilClass) && processor_config.filter_empty_string
        end

        # @api private
        def processor_config
          schema_dsl.processor_type.config
        end

        # @api private
        def primitives
          primitive_inferrer[schema_type]
        end

        # @api private
        def schema_type
          schema_dsl.types[name]
        end
      end
    end
  end
end
