module CachedResourceLibrary
  class Cache
    class Metadata
      attr_accessor :class_name, :instances, :collections

      def initialize(klass)
        self.class_name = klass.to_s
        self.instances = {}
        self.collections = []
      end

      def self.fetch(klass)
        object = CACHE_STORE.fetch(klass.to_s) do
          object = Metadata.new(klass)
          object && CachedResourceLibrary.log("WRITE METADATA #{klass}")
          object
        end

        object && CachedResourceLibrary.log("READ METADATA #{klass}")
        object
      end

      def save
        object = CACHE_STORE.write(class_name, self)
        CachedResourceLibrary.log("METADATA #{to_json}")
        object && CachedResourceLibrary.log("WRITE METADATA #{class_name}")
      end

      def add_collection(collection_key)
        add_instance(collection_key)
        collections << collection_key
        self.collections = collections.uniq
        self
      end

      def add_instance(instance_key, collection_key = nil)
        parent_collections = instances[instance_key] || []
        parent_collections << collection_key unless collection_key.nil?
        instances[instance_key] = parent_collections.uniq
        self
      end

      def collection?(key)
        self.collections.include?(key)
      end
    end
  end
end
