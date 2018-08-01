module QueryGrammar
  class Compiler
    autoload :ES, "query_grammar/compiler/es"

    class Cloaker < BasicObject
      attr_reader :bind, :closure

      def initialize bind:, closure: nil
        @bind = bind
        @closure = closure
      end

      def cloak *args, &block
        closure ||= block.binding

        # Ruby blocks don't closure over more than local variables, but we can
        # get around that with this "cloaker" hack. First we make an
        # unboundmethod which we rebind to our current instance. We also keep the
        # blocks original binding and with the method missing magic, proxy out to
        # it, which allows us to closure over methods and more from where the
        # block was defined at.
        executor = bind.class.class_eval do
          define_method :dsl_executor, &block
          meth = instance_method :dsl_executor
          remove_method :dsl_executor
          meth
        end

        with_closure_from closure do
          executor.bind(bind).call(*args)
        end
      end

      def with_closure_from binding
        @_parent_binding = binding
        result = yield
        @_parent_binding = nil
        result
      end

      # rubocop:disable Style/MethodMissing
      def respond_to_missing? *args
        @_parent_binding.respond_to_missing?(*args)
      end

      def method_missing method, *args, **opts, &block
        args << opts if opts.any?
        @_parent_binding.send method, *args, &block
      end
      # rubocop:enable Style/MethodMissing
    end

    class << self
      def visitors
        @visitors ||= ancestor_hash :visitors
      end

      def visit klass, &block
        visitors[ klass ] = block
      end

      protected

      # Allow classes to inherit their ancestors fields, joiners, types and
      # operations. This allows for progressively building searchers up, such as
      # having an ElasticsearchSearcher that defines the operations to build ES
      # queries, a BookmarksSearcher that inherits those operations while
      # defining public user facing searchable fields, and an
      # Admin::BookmarksSearcher which defines additional fields that are
      # available within the admin panel
      def ancestor_hash func
        (ancestors - [self])
          .select { |i| i.ancestors.include? Compiler }
          .inject({}) { |memo, i| memo.merge i.send func }
      end
    end

    def visit node
      visitor = self.class.visitors[ node.class ]
      Cloaker.new(bind: self).cloak node, &visitor
    end
  end
end
