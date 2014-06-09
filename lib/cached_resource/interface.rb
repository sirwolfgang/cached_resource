module CachedResource
  class << self
    def configuration=(configuration)
      CachedResourceLibrary::global_configuration = configuration
    end
    
    def configuration
      CachedResourceLibrary::global_configuration
    end
    
    def enable
      CachedResourceLibrary::global_configuration.enabled = true
    end
    
    def disable
      CachedResourceLibrary::global_configuration.enabled = false
    end
    
    def enabled?
      CachedResourceLibrary::global_configuration.enabled?
    end
    
    def clear_cache
      CachedResourceLibrary::Cache.clear
    end
  end

  def clear_cache
    if self.class == Class
      CachedResourceLibrary::Cache.clear_class(name)
    else
      CachedResourceLibrary::Cache.clear_instance(self)
    end
  end
    
  def cache_configuration
    @configuration ||= CachedResource::Configuration.new
  end
    
  def cache_configuration=(configuration)
    if self.class == Class
      @configuration = configuration
    else
      raise 'Can\'t set configuration for instance!'
    end
  end
    
  def enable_cache
    if self.class == Class
      cache_configuration.enabled = true
    else
      raise 'Can\'t set configuration for instance!'
    end
  end
    
  def disable_cache
    if self.class == Class
      cache_configuration.enabled = false
    else
      raise 'Can\'t set configuration for instance!'
    end
  end
    
  def cache_enabled?
    cache_configuration.enabled?
  end
end

module CachedResourceInterface 
  module Model
    extend ActiveSupport::Concern
    include CachedResource

    included do
      class << self
        alias_method_chain :find, :cache
      end
    end

    module ClassMethods
      include CachedResource

      def find_with_cache(*arguments)
        return find_without_cache(*arguments) unless cache_configuration.enabled?

        arguments << {} unless arguments.last.is_a?(Hash)
        reload = arguments.last.delete(:reload)
        arguments.pop if arguments.last.empty?

        CachedResourceLibrary.log("ARGS #{arguments}")
        
        if CachedResourceLibrary::Cache.collection?(name, *arguments) && cache_configuration.collection_synchronization?
          CachedResourceLibrary::Cache.fetch_with_collection(name, *arguments, reload) do
            find_without_cache(*arguments)
          end
        else
          CachedResourceLibrary::Cache.fetch(name, *arguments, reload) do
            find_without_cache(*arguments)
          end
        end
      end
    end
  end
end
