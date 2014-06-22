# lib/cached_resource_library.rb
module CachedResourceLibrary
  @@global_configuration = CachedResource::Configuration.new(
    enabled: true,
    collection_synchronization: false,
    collection_arguments: [:all])

  @@logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  @@cache_store = ActiveSupport::Cache::MemoryStore.new

  class << self
    def log(message)
      @@logger.tagged('cached_resource') { @@logger.info(message) }
    end

    def logger
      @@logger
    end

    def logger=(logger)
      @@logger = logger
    end

    def cache_store
      @@cache_store
    end

    def cache_store=(cache_store)
      @@cache_store = cache_store
    end

    def global_configuration
      @@global_configuration
    end

    def global_configuration=(configuration)
      @@global_configuration = configuration
    end
  end
end
