# lib/cached_resource_library/cache.rb
module CachedResourceLibrary
  class Cache
    class << self
      def fetch(name, *arguments, reload, &block)
        key = expand_cache_key([name] << arguments)

        cached_object = CACHE_STORE.fetch(key, force: reload) do
          object = block.call *arguments

          if object.is_a? ActiveResource::Collection
            metadata = Metadata.fetch(object.first.class.name)
            metadata.add_collection(key)
            object.each do |instance|
              instance_key = expand_cache_key([name] << instance.id)
              CACHE_STORE.write(instance_key, instance)
              metadata.add_instance(instance_key, key)
              CachedResourceLibrary.log("WRITE #{instance_key}")
            end
            metadata.save
          else
            Metadata.fetch(object.class.name).add_instance(key).save
          end

          object && CachedResourceLibrary.log("WRITE #{key}")
          object
        end

        cached_object && CachedResourceLibrary.log("READ #{key}")
        cached_object
      end

      def fetch_with_collection(name, *arguments, reload, &block)
        if !CACHE_STORE.exist?(expand_cache_key([name] << arguments)) || reload
          # TODO: Respect class settings
          fetch(name, CachedResourceLibrary::global_configuration.collection_arguments, true, &block)
        end
        fetch(name, *arguments, false, &block)
      end

      def clear
        CACHE_STORE.clear && CachedResourceLibrary.log('CLEAR ALL')
      end

      def clear_class(klass_name)
        Metadata.fetch(klass_name).instances.each do |key, _|
          CACHE_STORE.delete(key)
        end
        CachedResourceLibrary.log("CLEAR #{klass_name}")
      end

      def clear_instance(object)
        # TODO: Worry about parent collections
        instance_key = expand_cache_key([object.class.name, object.id])
        CACHE_STORE.delete(instance_key)
          
        # TODO: Respect class settings
        if CachedResourceLibrary::global_configuration.collection_synchronization?
        	Metadata.fetch(object.class.name).parent_collections(instance_key).each do |collection_key|
          	CACHE_STORE.delete(collection_key)
        	end
        end
        
        CachedResourceLibrary.log("CLEAR #{object.class.name}-#{object.id}")
      end

      def expand_cache_key(arguments)
        ActiveSupport::Cache.expand_cache_key(arguments, 'cached_resource')
      end

      def collection?(name, *arguments)
        # TODO: Respect class settings
        return true if CachedResourceLibrary::global_configuration.collection_arguments == arguments
        Metadata.fetch(name).collection?(expand_cache_key([name] << arguments))
      end
    end
  end
end
