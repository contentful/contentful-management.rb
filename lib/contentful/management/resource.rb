require 'date'
require_relative 'resource/refresher'
require_relative 'resource/system_properties'

module Contentful
  module Management
    # Include this module to declare a class to be a contentful resource.
    # This is done by the default in the existing resource classes
    #
    # You can define your own classes that behave like contentful resources:
    # See examples/custom_classes.rb to see how.
    #
    # Take a look at examples/resource_mapping.rb on how to register them to be returned
    # by the client by default
    #
    # @see _ examples/custom_classes.rb Custom Class as Resource
    # @see _ examples/resource_mapping.rb Mapping a Custom Class
    module Resource
      # @private
      # rubocop:disable Style/DoubleNegation
      COERCIONS = {
        string: ->(value) { !value.nil? ? value.to_s : nil },
        integer: ->(value) { value.to_i },
        float: ->(value) { value.to_f },
        boolean: ->(value) { !!value },
        date: ->(value) { !value.nil? ? DateTime.parse(value) : nil }
      }.freeze
      # rubocop:enable Style/DoubleNegation

      attr_reader :properties, :request, :default_locale, :raw_object
      attr_accessor :client

      # @private
      def initialize(object = nil,
                     request = nil,
                     client = nil,
                     nested_locale_fields = false,
                     default_locale = Contentful::Management::Client::DEFAULT_CONFIGURATION[:default_locale])
        self.class.update_coercions!
        @nested_locale_fields = nested_locale_fields
        @default_locale = default_locale

        @properties = extract_from_object object, :property, self.class.property_coercions.keys
        @request = request
        @client = client
        @raw_object = object
      end

      # @private
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @private
      def after_create(_attributes); end

      # Updates a resource.
      #
      # @param [Hash] attributes
      #
      # @see _ README for more information on how to create each resource
      #
      # @return [Contentful::Management::Resource]
      def update(attributes)
        headers = self.class.create_headers(client, attributes, self)
        headers = headers.merge(update_headers)

        ResourceRequester.new(client, self.class).update(
          self,
          update_url_attributes,
          query_attributes(attributes),
          headers
        )
      end

      # Creates or updates a resource.
      #
      # @return [Contentful::Management::Resource]
      def save
        update({})
      end

      # Destroys a resource.
      #
      # @return [true, Contentful::Management::Error] success
      def destroy
        ResourceRequester.new(client, self.class).destroy(
          space_id: space.id,
          environment_id: environment_id,
          resource_id: id
        )
      end

      # @private
      def inspect(info = nil)
        properties_info = properties.empty? ? '' : " @properties=#{properties.inspect}"
        "#<#{self.class}:#{properties_info}#{info}>"
      end

      # Returns true for resources that behave like an array
      def array?
        false
      end

      # By default, fields come flattened in the current locale. This is different for syncs
      def nested_locale_fields?
        # rubocop:disable Style/DoubleNegation
        !!@nested_locale_fields
        # rubocop:enable Style/DoubleNegation
      end

      # Resources that don't include SystemProperties return nil for #sys
      def sys
        nil
      end

      # Resources that don't include Fields or AssetFields return nil for #fields
      def fields
        nil
      end

      # Shared instance of the API client
      def client
        Contentful::Management::Client.shared_instance
      end

      # @return [true]
      def resource?
        true
      end

      # Returns the Environment ID
      def environment_id
        nil
      end

      protected

      def update_headers
        { version: sys[:version] }
      end

      def update_url_attributes
        {
          space_id: space.id,
          environment_id: environment_id,
          resource_id: id
        }
      end

      def query_attributes(attributes)
        attributes
      end

      private

      def internal_resource_locale
        sys.fetch(:locale, nil) || default_locale
      end

      def extract_from_object(object, namespace, keys = nil)
        if object
          keys ||= object.keys
          keys.each.with_object({}) do |name, res|
            res[name.to_sym] = coerce_value_or_array(
              object.is_a?(::Array) ? object : object[name.to_s],
              self.class.public_send(:"#{namespace}_coercions")[name.to_sym]
            )
          end
        else
          {}
        end
      end

      def coerce_value_or_array(value, what = nil)
        if value.is_a? ::Array
          value.map { |row| coerce_or_create_class(row, what) }
        else
          coerce_or_create_class(value, what)
        end
      end

      def coerce_or_create_class(value, what)
        case what
        when Symbol
          COERCIONS[what] ? COERCIONS[what][value] : value
        when Class
          what.new(value, client)
        when Proc
          what[value]
        else
          value
        end
      end

      # Register the resources properties on class level by using the #property method
      module ClassMethods
        # @private
        def endpoint
          "#{Support.snakify(name.split('::')[-1])}s"
        end

        # @private
        def build_endpoint(endpoint_options)
          if endpoint_options.key?(:public)
            base = "spaces/#{endpoint_options[:space_id]}"
            base = "#{base}/environments/#{endpoint_options[:environment_id]}" if endpoint_options[:environment_id]
            return "#{base}/public/#{endpoint}"
          end

          base = "spaces/#{endpoint_options[:space_id]}"
          base = "#{base}/environments/#{endpoint_options[:environment_id]}" if endpoint_options[:environment_id]
          base = "#{base}/#{endpoint}"
          return "#{base}/#{endpoint_options[:resource_id]}#{endpoint_options[:suffix]}" if endpoint_options[:resource_id]
          base
        end

        # Gets a collection of resources.
        #
        # @param [Contentful::Management::Client] client
        # @param [String] space_id
        # @param [Hash] parameters Search Options
        # @see _ For complete option list: https://www.contentful.com/developers/docs/references/content-delivery-api/#/reference/search-parameters
        #
        # @return [Contentful::Management::Array<Contentful::Management::Resource>]
        def all(client, space_id, environment_id = nil, parameters = {})
          ResourceRequester.new(client, self).all({ space_id: space_id, environment_id: environment_id }, parameters)
        end

        # Gets a specific resource.
        #
        # @param [Contentful::Management::Client] client
        # @param [String] space_id
        # @param [String] resource_id
        #
        # @return [Contentful::Management::Resource]
        def find(client, space_id, environment_id = nil, resource_id = nil)
          ResourceRequester.new(client, self).find(space_id: space_id, environment_id: environment_id, resource_id: resource_id)
        end

        # Creates a resource.
        #
        # @param [Contentful::Management::Client] client
        # @param [String] space_id
        # @param [String] environment_id
        # @param [Hash] attributes
        # @see _ README for full attribute list for each resource.
        #
        # @return [Contentful::Management::Resource]
        def create(client, space_id, environment_id = nil, attributes = {})
          endpoint_options = { space_id: space_id, environment_id: environment_id }
          endpoint_options[:resource_id] = attributes[:id] if attributes.respond_to?(:key) && attributes.key?(:id)
          ResourceRequester.new(client, self).create(
            endpoint_options,
            attributes
          )
        end

        # @private
        def pre_process_params(parameters)
          parameters
        end

        # @private
        def create_attributes(_client, _attributes)
          {}
        end

        # @private
        def create_headers(_client, _attributes, _instance = nil)
          {}
        end

        # By default, fields come flattened in the current locale. This is different for sync
        def nested_locale_fields?
          false
        end

        # Default property coercions
        def property_coercions
          @property_coercions ||= {}
        end

        # Defines which properties of a resource your class expects
        # Define them in :camelCase, they will be available as #snake_cased methods
        #
        # You can pass in a second "type" argument:
        # - If it is a class, it will be initialized for the property
        # - Symbols are looked up in the COERCION constant for a lambda that
        #   defines a type conversion to apply
        #
        # Note: This second argument is not meant for contentful sub-resources,
        # but for structured objects (like locales in a space)
        # Sub-resources are handled by the resource builder
        def property(name, property_class = nil)
          property_coercions[name.to_sym] = property_class
          accessor_name = Contentful::Management::Support.snakify(name)
          define_method accessor_name do
            properties[name.to_sym]
          end
          define_method "#{accessor_name}=" do |value|
            properties[name.to_sym] = value
          end
        end

        # Ensure inherited classes pick up coercions
        def update_coercions!
          return if @coercions_updated

          if superclass.respond_to? :property_coercions
            @property_coercions = superclass.property_coercions.dup.merge(@property_coercions || {})
          end

          if superclass.respond_to? :sys_coercions
            @sys_coercions = superclass.sys_coercions.dup.merge(@sys_coercions || {})
          end

          if superclass.respond_to? :fields_coercions
            @fields_coercions = superclass.fields_coercions.dup.merge(@fields_coercions || {})
          end

          @coercions_updated = true
        end
      end
    end
  end
end
