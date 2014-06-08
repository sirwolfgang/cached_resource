module CachedResourceLibrary
  @@global_configuration = CachedResource::Configuration.new(enabled: true, collection_synchronize: false, collection_arguments: [:all])
  LOGGER = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  CACHE_STORE = ActiveSupport::Cache::MemoryStore.new
  
  class << self
    def log(message)
      LOGGER.tagged('cached_resource') { LOGGER.info(message) }
    end
    
    def global_configuration
      @@global_configuration
    end
    
    def global_configuration=(configuration)
      @@global_configuration = configuration
    end
  end
end
