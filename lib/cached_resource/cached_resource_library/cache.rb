# lib/cached_resource_library/cache.rb
module CachedResourceLibrary
  class Cache
    class << self
      def fetch(name, *arguments, reload, &block)
        key = expand_cache_key([name] << arguments)

        cached_object = CACHE_STORE.fetch(key, force: reload) do
          object = block.call

          if object.is_a? ActiveResource::Collection
            Metadata.fetch(object.first.class.name).add_collection(key).save
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
        unless CACHE_STORE.exist?(expand_cache_key([name] << arguments)) || reload
          fetch(name, [:all], true, &block)
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
        CACHE_STORE.delete(expand_cache_key([object.class.name, object.id]))
        CachedResourceLibrary.log("CLEAR #{object.class.name}-#{object.id}")
      end

      def expand_cache_key(arguments)
        ActiveSupport::Cache.expand_cache_key(arguments, 'cached_resource')
      end

      def collection?(name, *arguments)
        return true if [:all].include?(arguments.first)
        Metadata.fetch(name).collection?(expand_cache_key([name] << arguments))
      end
    end
  end
end
