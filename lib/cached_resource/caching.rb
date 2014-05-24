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
        
        cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} ARGS #{arguments}")
        fetch(*arguments, reload)
      end
      
      def clear_cache
        # Clear Collection Cache
        # Note:: The current usage of `Class.clear_cache` implies the clearing of class based cache, not entire module cache; Which is the current implementation
        cached_resource.cache.clear && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} CLEAR")
      end
      
      private
      
      def fetch(*arguments, reload)
        key = build_key(*arguments)
        
        cached_object = cached_resource.cache.fetch(key, force: reload, expires_in: cached_resource.generate_ttl) do
          object = find_without_cache(*arguments)
          object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} WRITE #{key}")
          object
        end
        
        update_with_collection(cached_object) if cached_resource.collection_synchronize and cached_object.is_a? ActiveResource::Collection
        
        cached_object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} READ #{key}")
        cached_object
      end
        
      def update(key, object)
        cached_object = cached_resource.cache.write(key, object, expires_in: cached_resource.generate_ttl)
        cached_object && cached_resource.logger.info("#{CachedResource::Configuration::LOGGER_PREFIX} WRITE #{key}")
      end

      def update_with_collection(collection)
        collection.each do |object|
          # TODO:: See about allowing custom/non id based primary_keys, most likly will have to manually set much like collection argument
          update(build_key(object.id), object)
        end
      end
      
      def build_key(*arguments)
        "#{name.parameterize.gsub("-", "/")}/#{arguments.join('/')}".downcase.delete(' ')
      end
      
    end
  end
end
