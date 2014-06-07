module CachedResource
  module Model
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods
      def find_with_cache(*arguments)
        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?
        
        CachedResource::Private.log("ARGS #{arguments}")
        CachedResource::Private::Cache.fetch(name, *arguments, reload) do
          find_without_cache(*arguments)
        end
      end
    end
  end
end