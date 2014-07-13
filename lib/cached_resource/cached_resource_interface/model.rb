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

    module InstanceMethods
      include CachedResource
      attr_accessor :cache_key
    end
    
    def cache_update(update)
      cache = CachedResourceLibrary::Cache.new(self.class.name, cache_configuration)
      cache.update_instance(self, update)
    end

    module ClassMethods
      include CachedResource

      def find_with_cache(*arguments)
        return find_without_cache(*arguments) unless cache_configuration.enabled?

        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?

        CachedResourceLibrary.log("Cache Request #{name}/#{arguments}")

        fetch_without_cache = proc do |*request_arguments|
          CachedResourceLibrary.log("HTTP Request #{name}/#{request_arguments}")
          find_without_cache(*request_arguments)
        end

        cache = CachedResourceLibrary::Cache.new(name, cache_configuration)

        if !cache.collection?(*arguments) && cache_configuration.collection_synchronization?
          cache.fetch_with_collection(*arguments, reload, &fetch_without_cache)
        else
          cache.fetch(*arguments, reload, &fetch_without_cache)
        end
      end
      
      def cache_read(*arguments)
        
        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?
        
        cache = CachedResourceLibrary::Cache.new(name, cache_configuration)
        cache.read(*arguments)
      end
      
    end
  end
end
