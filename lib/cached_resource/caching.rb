module CachedResource
  module Private
    class Cache
      class << self
        def fetch(name, *arguments, reload, &block)
          key = expand_cache_key([name] << arguments)
          
          cached_object = CACHE_STORE.fetch(key, force: reload) do
            object = block.call
            
            if object.is_a? ActiveResource::Collection
              Metadata.fetch(object.first.class.name.parameterize).add_collection(key).save
            else
              Metadata.fetch(object.class.name.parameterize).add_instance(key, nil).save
            end
             
            object && CachedResource::Private.log("WRITE #{key}")
            object
          end

          cached_object && CachedResource::Private.log("READ #{key}")
          cached_object
        end

        def update(key, object)
          cached_object = CACHE_STORE.write(key, object)
          cached_object && CachedResource::Private.log("WRITE #{key}")
        end

        def clear
          CACHE_STORE.clear && CachedResource::Private.log("CLEAR")
        end

        def expand_cache_key(arguments)
          ActiveSupport::Cache.expand_cache_key(arguments, "cached_resource")
        end
      end
    end
  end
end