module CachedResource
  module Private
    class Cache
      class Metadata
        attr_accessor :class_name, :instances, :collections

        # {
        #   collections: ['/all'],
        #   instances: {
        #     '/1' => ['/all']
        #   }
        # }

        def initialize(klass)
          self.class_name = klass.to_s
          self.instances = {}
          self.collections = []
        end

        def self.fetch(klass)
          object = CACHE_STORE.fetch(klass.to_s) do
            object = Metadata.new(klass)
            object && CachedResource::Private.log("WRITE METADATA #{klass}")
            object
          end

          object && CachedResource::Private.log("READ METADATA #{klass}")
          object
        end

        def save
          object = CACHE_STORE.write(class_name, self)
          CachedResource::Private.log("METADATA #{self.to_json}")
          object && CachedResource::Private.log("WRITE METADATA #{class_name}")
        end

        def add_collection(collection_key)
          self.collections << collection_key
          self.collections = self.collections.uniq
        end

        def add_instance(instance_key, collection_key)
          parent_collections = self.instances[instance_key] || []
          parent_collections << collection_key unless collection_key.nil?
          self.instances[instance_key] = parent_collections.uniq
        end
      end
    end
  end
end