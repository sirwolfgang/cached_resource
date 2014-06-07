module CachedResource
  module Private
    LOGGER = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
    CACHE_STORE = ActiveSupport::Cache::MemoryStore.new

    def self.log(message)
      LOGGER.tagged('cached_resource') { LOGGER.info(message) }
    end
  end
end
