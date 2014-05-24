module CachedResource
  # The Caching module is included in ActiveResource and
  # handles caching and recaching of responses.
  module Caching
    extend ActiveSupport::Concern

    included do
      class << self
        alias_method_chain :find, :cache
      end
      
      def clear_cache
        # Clear Instance Cache
      end
    end

    
    module ClassMethods
      
      def find_with_cache(*arguments)
        return find_without_cache(*arguments) unless cached_resource.enabled
        
        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?
        
        fetch(*arguments, reload)
      end
      
      def clear_cache
        # Clear Collection Cache
      end
      
      private
      
      def fetch(*arguments, reload)
        key = build_key(*arguments)
        
        cached_object = cached_resource.cache.fetch(key, force: reload, expires_in: cached_resource.generate_ttl) do
          object = find_without_cache(*arguments)
          object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} WRITE #{key}")
        end
        
        cached_object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} READ #{key}")
        cached_object
      end

      def build_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase.delete(' ')
      end
      
    end
  end
end
