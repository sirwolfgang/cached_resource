module CachedResourceLibrary
  class Railtie < Rails::Railtie
    config.after_initialize do
      CachedResourceLibrary::CACHE_STORE = Rails.cache
      CachedResourceLibrary::LOGGER = Rails.logger
    end
  end
end
