module CachedResource
  class Cache
    CACHE_STORE = ActiveSupport::Cache::MemoryStore.new
    
    class << self
      def fetch(*arguments, reload, &block)
        key = build_key(*arguments)
        metadata = nil

        cached_object = CACHE_STORE.fetch(key, force: reload) do
          object = block.call
          metadata = Metadata.fetch(object.class.name.parameterize)

         # if cached_resource.collection_synchronize and object.is_a? ActiveResource::Collection
         #   update_with_collection(object)
         #   metadata.add_collection(key)
         # else
           metadata.add_instance(key, nil)
         # end
           metadata.save
      
          object && CachedResource::log("WRITE #{key}")
          object
        end

        cached_object && CachedResource::log("READ #{key}")
        cached_object
      end

      def fetch_with_collection(*arguments, reload)
        fetch([:all], true) unless CACHE_STORE.exist?(build_key(*arguments)) || reload
        fetch(*arguments, false)
      end

      def update(key, object)
        cached_object = CACHE_STORE.write(key, object)
        cached_object && CachedResource::log("WRITE #{key}")
      end

      def update_with_collection(collection)
        collection.each do |object|
          update(build_key(object.id), object)
        end
      end
      
      def clear
        CACHE_STORE.clear && CachedResource::log("CLEAR")
      end

      def build_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase.delete(' ')
      end

      def is_collection?(*arguments)
        arguments == [:all]
      end
    end
  end
end