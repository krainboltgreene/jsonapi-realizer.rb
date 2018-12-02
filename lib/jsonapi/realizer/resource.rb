module JSONAPI
  module Realizer
    module Resource
      require_relative("resource/configuration")
      require_relative("resource/attribute")
      require_relative("resource/relation")

      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)

      MIXIN_HOOK = ->(*) do
        @attributes = {}
        @relations = {}

        unless const_defined?("Context")
          self::Context = Class.new do
            include(JSONAPI::Realizer::Context)

            def initialize(**keyword_arguments)
              keyword_arguments.keys.each(&singleton_class.method(:attr_accessor))

              super(**keyword_arguments)
            end
          end
        end

        validates_presence_of(:intent)
        validates_presence_of(:parameters, :allow_empty => true)
        validates_presence_of(:headers, :allow_empty => true)

        identifier(JSONAPI::Realizer.configuration.default_identifier)

        has(JSONAPI::Realizer.configuration.default_identifier)
      end
      private_constant :MIXIN_HOOK

      attr_writer(:intent)
      attr_accessor(:parameters)
      attr_accessor(:headers)
      attr_writer(:context)
      attr_accessor(:scope)

      def initialize(**keyword_arguments)
        super(**keyword_arguments)

        context.validate!
        validate!

        if filtering?
          @scope = adapter.filtering(scope, filters)
        end

        if include?
          @scope = adapter.include_relationships(scope, includes)
        end

        if sorting?
          @scope = adapter.sorting(scope, sorts)
        end

        if paginate?
          @scope = adapter.paginate(scope, *pagination)
        end

        if writing? && data?
          adapter.write_attributes(object, attributes)
          adapter.write_relationships(object, relationships)
        end
      end

      def to_hash
        @native ||= {
          :pagination => if paginate? then pagination end,
          :selects => if selects? then selects end,
          :includes => if include? then includes end,
          :object => object
        }.compact
      end

      private def writing?
        [:create, :update].include?(intent)
      end

      def paginate?
        parameters.key?("page") && (parameters.fetch("page").key?("limit") || parameters.fetch("page").key?("offset"))
      end

      def pagination
        [
          parameters.fetch("page").fetch("limit", nil),
          parameters.fetch("page").fetch("offset", nil)
        ]
      end

      def sorting?
        parameters.key?("sort")
      end

      def sorts
        @sorts ||= parameters.
          # {sort: "name,-age,accounts.created_at,-accounts.updated_at"}
          fetch("sort").
          # "name,-age,accounts.created_at,-accounts.updated_at"
          split(",").
          # ["name", "-age", "accounts.created_at", "-accounts.updated_at"]
          map do |token|
            if token.start_with?("-") then [token.sub(/^-/, "").underscore, "-"] else [token.underscore, "+"] end
          end.
          # [["name", "+"], ["age", "-"], ["accounts.created_at", "+"], ["accounts.updated_at", "-"]]
          map do |(path, direction)|
            [if path.include?(".") then path.split(".") else [self.class.configuration.type, path] end, direction]
          end
          # [[["accounts", "name"], "+"], [["accounts", "age"], "-"], [["accounts", "created_at"], "+"], [["accounts", "updated_at"], "-"]]
      end

      def filtering?
        parameters.key?("filter")
      end

      def filters
        @filters ||= parameters.
          # {"filter" => {"full-name" => "Abby Marquardt", "email" => "amado@goldner.com"}}
          fetch("filter").
          # {"full-name" => "Abby Marquardt", "email" => "amado@goldner.com"}
          transform_keys(&:underscore)
          # {"full_name" => "Abby Marquardt", "email" => "amado@goldner.com"}
      end

      def include?
        parameters.key?("include")
      end

      def includes
        @includes ||= parameters.
          # {"include" => "active-photographer.photographs,comments,comments.author"}
          fetch("include").
          # "active-photographer.photographs,comments,comments.author"
          split(/\s*,\s*/).
          # ["active-photographer.photographs", "comments", "comments.author"]
          map {|chain| chain.split(".")}.
          # [["active-photographer", "photographs"], ["comments"], ["comments", "author"]]
          map {|list| list.map(&:underscore)}.
          # [["active_photographer", "photographs"], ["comments"], ["comments", "author"]]
          map do |relationship_chain|
            # This walks down the path of relationships and normalizes thenm to
            # their defined "as", which lets us expose AccountRealizer#name, but that actually
            # references Account#full_name.
            relationship_chain.reduce([[], self.class]) do |(normalized_relationship_chain, realizer_class), relationship_link|
              [
                [
                  *normalized_relationship_chain,
                  realizer_class.relation(relationship_link).as
                ],
                realizer_class.relation(relationship_link).realizer_class
              ]
            end.first
          end
          # [["account", "photographs"], ["comments"], ["comments", "account"]]
      end

      def selects?
        parameters.key?("fields")
      end

      def selects
        @selects ||= parameters.
          # {"fields" => {"articles" => "title,body,sub-text", "people" => "name"}}
          fetch("fields").
          # {"articles" => "title,body,sub-text", "people" => "name"}
          transform_keys(&:underscore).
          # {"articles" => "title,body,sub-text", "people" => "name"}
          transform_values {|value| value.split(/\s*,\s*/)}.
          # {"articles" => ["title", "body", "sub-text"], "people" => ["name"]}
          transform_values {|value| value.map(&:underscore)}
          # {"articles" => ["title", "body", "sub_text"], "people" => ["name"]}
      end

      private def data?
        parameters.key?("data")
      end

      private def data
        @data ||= parameters.fetch("data")
      end

      private def type
        return unless data.key?("type")

        @type ||= data.fetch("type")
      end

      def attributes
        return unless data.key?("attributes")

        @attributes ||= data.
          fetch("attributes").
          transform_keys(&:underscore).
          transform_keys{|key| attribute(key).as}
      end

      def relationships
        return unless data.key?("relationships")

        @relationships ||= data.
          fetch("relationships").
          transform_keys(&:underscore).
          map(&method(:as_relationship)).to_h.
          transform_keys{|key| relation(key).as}
      end

      private def scope
        @scope ||= adapter.find_many(@scope || model_class)
      end

      def object
        @object ||= case intent
        when :create
          scope.new
        when :show, :update, :destroy
          adapter.find_one(scope, parameters.fetch("id"))
        else
          scope
        end
      end

      def intent
        @intent.to_sym
      end

      private def as_relationship(name, value)
        data = value.fetch("data")

        relation_configuration = relation(name).realizer_class.configuration

        if data.is_a?(Array)
          [name, relation_configuration.adapter.find_many(relation_configuration.model_class, {id: data.map {|value| value.fetch("id")}})]
        else
          [name, relation_configuration.adapter.find_one(relation_configuration.model_class, data.fetch("id"))]
        end
      end

      private def attribute(name)
        self.class.attribute(name)
      end

      private def relation(name)
        self.class.relation(name)
      end

      private def adapter
        self.class.configuration.adapter
      end

      private def model_class
        self.class.configuration.model_class
      end

      def context
        self.class.const_get("Context").new(**@context || {})
      end

      included do
        class_eval(&MIXIN_HOOK) unless @abstract_class
      end

      class_methods do
        def inherited(object)
          object.class_eval(&MIXIN_HOOK) unless object.instance_variable_defined?(:@abstract_class)
        end

        def identifier(value)
          @identifier ||= value.to_sym
        end

        def type(value, class_name:, adapter:)
          @type ||= value.to_s
          @model_class ||= class_name.constantize
          @adapter ||= JSONAPI::Realizer::Adapter.new(interface: adapter)
        end

        def has(name, as: name)
          @attributes[name] ||= Attribute.new(
            :name => name,
            :as => as,
            :owner => self
          )
        end

        def has_one(name, as: name, class_name:)
          @relations[name] ||= Relation.new(
            :owner => self,
            :type => :one,
            :name => name,
            :as => as,
            :realizer_class_name => class_name
          )
        end

        def has_many(name, as: name, class_name:)
          @relations[name] ||= Relation.new(
            :owner => self,
            :type => :many,
            :name => name,
            :as => as,
            :realizer_class_name => class_name
          )
        end

        def context
          const_get("Context")
        end

        def configuration
          @configuration ||= Configuration.new({
            :owner => self,
            :type => @type,
            :model_class => @model_class,
            :adapter => @adapter,
            :attributes => @attributes,
            :relations => @relations
          })
        end

        def attribute(name)
          configuration.attributes.fetch(name.to_sym){raise(Error::ResourceRelationshipNotFound, name: name, realizer: self)}
        end

        def relation(name)
          configuration.relations.fetch(name.to_sym){raise(Error::ResourceRelationshipNotFound, name: name, realizer: self)}
        end
      end
    end
  end
end
