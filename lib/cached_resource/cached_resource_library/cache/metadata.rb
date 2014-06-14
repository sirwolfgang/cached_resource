# lib/cached_resource_library/cache/metadata.rb
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
          object
        end

        object
      end

      def save
        CACHE_STORE.write(class_name, self)
      end

      def add_collection(collection_key)
        add_instance(collection_key)
        collections << collection_key
        collections.uniq!
        self
      end

      def add_instance(instance_key, collection_key = nil)
        parent_collections = instances[instance_key] || []
        parent_collections << collection_key unless collection_key.nil?
        instances[instance_key] = parent_collections.uniq
        self
      end

      def parent_collections(instance_key)
        instances[instance_key]
      end

      def collection?(key)
        collections.include?(key)
      end
    end
  end
end
