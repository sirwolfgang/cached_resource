# lib/cached_resource_interface/model.rb
module CachedResourceInterface
  module Model
    extend ActiveSupport::Concern
    include CachedResource

    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods
      include CachedResource

      def find_with_cache(*arguments)
        return find_without_cache(*arguments) unless cache_configuration.enabled?

        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?

        CachedResourceLibrary.log("ARGS #{arguments}")

        if CachedResourceLibrary::Cache.collection?(name, *arguments) && cache_configuration.collection_synchronization?
          CachedResourceLibrary::Cache.fetch_with_collection(name, *arguments, reload) do
            find_without_cache(*arguments)
          end
        else
          CachedResourceLibrary::Cache.fetch(name, *arguments, reload) do
            find_without_cache(*arguments)
          end
        end
      end

    end
  end
end
