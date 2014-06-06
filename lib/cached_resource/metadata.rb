module CachedResource
  class Metadata
    attr_accessor :instances, :collections
    
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
      object = Cache.fetch(klass.to_s) do
        object = Metadata.new(klass)
        object && Cache::LOGGER.info("#{Cache::LOGGER_TAG} WRITE METADATA #{key}")
        object
      end

      object && Cache::LOGGER.info("#{Cache::LOGGER_TAG} READ METADATA #{key}")
      object
    end
    
    def save
      object = Cache.write(class_name, self)
      Cache::LOGGER.info("#{Cache::LOGGER_TAG} METADATA #{self.to_json}")
      object && Cache::LOGGER.info("#{Cache::LOGGER_TAG} WRITE METADATA #{key}")
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