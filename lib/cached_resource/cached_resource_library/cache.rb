# lib/cached_resource_library/cache.rb
module CachedResourceLibrary
  class Cache
    attr_accessor :klass_name, :metadata, :configuration, :cache

    def initialize(klass_name, configuration)
      @klass_name = klass_name
      @metadata = Metadata.fetch(klass_name)
      @configuration = configuration
    end

    def fetch(*arguments, reload, &block)
      key = expand_cache_key(arguments)

      cached_object = CachedResourceLibrary.cache_store.fetch(key, force: reload) do
        object = block.call(*arguments)

        if object.is_a? ActiveResource::Collection
          metadata.add_collection(key)

          object.each do |instance|
            instance_key = expand_cache_key(instance.id)
            CachedResourceLibrary.cache_store.write(instance_key, instance)
            metadata.add_instance(instance_key, key)
            CachedResourceLibrary.log("WRITE #{instance_key}")
          end
        else
          metadata.add_instance(key)
        end

        object && CachedResourceLibrary.log("WRITE #{key}")
        object
      end

      metadata.save
      cached_object && CachedResourceLibrary.log("READ #{key}")
      cached_object
    end

    def fetch_with_collection(*arguments, reload, &block)
      if !CachedResourceLibrary.cache_store.exist?(expand_cache_key(arguments)) || reload
        fetch(configuration.observed_collection_arguments, true, &block)
      end
      fetch(*arguments, false, &block)
    end

    def self.clear
      CachedResourceLibrary.cache_store.clear && CachedResourceLibrary.log('CLEAR ALL')
    end

    def clear_class
      metadata.instances.each do |key, _|
        CachedResourceLibrary.cache_store.delete(key)
      end
      CachedResourceLibrary.log("CLEAR #{klass_name}")
    end

    def clear_instance(object)
      instance_key = expand_cache_key(object.id)
      CachedResourceLibrary.cache_store.delete(instance_key)

      if configuration.collection_synchronization?
        metadata.parent_collections(instance_key).each do |collection_key|
          CachedResourceLibrary.cache_store.delete(collection_key)
        end
      end

      CachedResourceLibrary.log("CLEAR #{klass_name}/#{object.id}")
    end

    def collection?(*arguments)
      return true if configuration.observed_collection_arguments == arguments
      metadata.collection?(expand_cache_key(arguments))
    end

    private

    def expand_cache_key(arguments)
      arguments = [klass_name] << arguments
      ActiveSupport::Cache.expand_cache_key(arguments, 'cached_resource')
    end
  end
end
