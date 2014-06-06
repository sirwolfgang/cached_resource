module CachedResource
  class Railtie < Rails::Railtie
    config.after_initialize do
      CachedResource::Cache::CACHE_STORE = Rails.cache
    end
  end
end