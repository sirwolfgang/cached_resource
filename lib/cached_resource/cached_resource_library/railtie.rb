# lib/cached_resource_library/railtie.rb
module CachedResourceLibrary
  class Railtie < Rails::Railtie
    config.after_initialize do
      CachedResourceLibrary.cache_store = Rails.cache
      CachedResourceLibrary.logger = Rails.logger
    end
  end
end
