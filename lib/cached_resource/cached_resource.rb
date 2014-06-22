# lib/cached_resource/cached_resource.rb
module CachedResource
  class << self
    def configuration=(configuration)
      CachedResourceLibrary.global_configuration = configuration
    end

    def configuration
      CachedResourceLibrary.global_configuration
    end

    def enable
      CachedResourceLibrary.global_configuration.enabled = true
    end

    def disable
      CachedResourceLibrary.global_configuration.enabled = false
    end

    def enabled?
      CachedResourceLibrary.global_configuration.enabled?
    end

    def clear_cache
      CachedResourceLibrary::Cache.clear
    end
  end

  def clear_cache
    if self.class == Class
      CachedResourceLibrary::Cache.new(name, cache_configuration).clear_class
    else
      CachedResourceLibrary::Cache.new(self.class.name, cache_configuration).clear_instance(self)
    end
  end

  def cache_configuration
    @configuration ||= CachedResource::Configuration.new
  end

  def cache_configuration=(configuration)
    if self.class == Class
      @configuration = configuration
    else
      fail 'Can\'t set configuration for instance!'
    end
  end

  def enable_cache
    if self.class == Class
      cache_configuration.enabled = true
    else
      fail 'Can\'t set configuration for instance!'
    end
  end

  def disable_cache
    if self.class == Class
      cache_configuration.enabled = false
    else
      fail 'Can\'t set configuration for instance!'
    end
  end

  def cache_enabled?
    cache_configuration.enabled?
  end
end
