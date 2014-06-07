module CachedResource
  module Private
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

            object && CachedResource::Private.log("WRITE #{key}")
            object
          end

          cached_object && CachedResource::Private.log("READ #{key}")
          cached_object
        end

        def clear
          CACHE_STORE.clear && CachedResource::Private.log('CLEAR ALL')
        end

        def clear_class(klass_name)
          Metadata.fetch(klass_name).instances.each do |key, _|
            CACHE_STORE.delete(key)
          end
          CachedResource::Private.log("CLEAR #{klass_name}")
        end

        def clear_instance(object)
          # TODO: Worry about parent collections
          CACHE_STORE.delete(expand_cache_key([object.class.name, object.id]))
          CachedResource::Private.log("CLEAR #{object.class.name}-#{object.id}")
        end

        def expand_cache_key(arguments)
          ActiveSupport::Cache.expand_cache_key(arguments, 'cached_resource')
        end
      end
    end
  end
end
