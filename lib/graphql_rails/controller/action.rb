# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'
require 'graphql_rails/errors/error'
require 'graphql_rails/model'
require_relative 'request'

module GraphqlRails
  class Controller
    # analyzes route and extracts controller action related data
    class Action
      def initialize(route)
        @route = route
      end

      def return_type(group: nil)
        action_config.return_type(group: group)
      end

      def arguments
        action_config.attributes.values
      end

      def controller
        @controller ||= "#{namespaced_controller_name}_controller".classify.constantize
      end

      def name
        @name ||= action_relative_path.split('#').last
      end

      def description
        action_config.description
      end

      def type_args
        [type_parser.type_arg, null: !type_parser.required?]
      end

      private

      attr_reader :route

      delegate :type_parser, to: :action_config

      def action_relative_path
        route.relative_path
      end

      def action_config
        controller.controller_configuration.action(name)
      end

      def namespaced_controller_name
        [route.module_name, controller_name].reject(&:empty?).join('/')
      end

      def controller_name
        @controller_name ||= action_relative_path.split('#').first
      end

      def namespaced_model_name
        namespaced_controller_name.singularize.classify
      end
    end
  end
end
