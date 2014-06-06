module CachedResource
  LOGGER = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  
  class << self
    def log(message)
      LOGGER.tagged('cached_resource') { LOGGER.info(message) }
    end
  end
  
  module Model
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods
      def find_with_cache(*arguments)
        #return find_without_cache(*arguments) #unless cached_resource.enabled

        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?
        
        CachedResource::log("ARGS #{arguments}")
        
        #if cached_resource.collection_synchronize && not(is_collection?(arguments[0]))
        #  Cache.fetch_via_collection(*arguments, reload)
        #else 
        Cache.fetch(*arguments, reload) do
          find_without_cache(*arguments)
        end
        #end
      end
    end

  end
end