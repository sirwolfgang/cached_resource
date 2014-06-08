require 'active_resource'
require 'active_support/concern'
require 'cached_resource/railtie' if defined?(Rails)
require 'cached_resource/configuration'
require 'cached_resource/interface'
require 'cached_resource/metadata'
require 'cached_resource/caching'
require 'cached_resource/version'
require 'cached_resource/cached_resource'

module ActiveResource
  class Base
    include CachedResourceInterface::Model
  end
end
