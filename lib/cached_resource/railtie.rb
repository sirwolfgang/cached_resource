module CachedResource
  class Railtie < Rails::Railtie
    config.after_initialize do
      CachedResource::Private::CACHE_STORE = Rails.cache
      CachedResource::Private::LOGGER = Rails.logger
    end
  end
end
