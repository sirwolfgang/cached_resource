require 'active_resource'
require 'active_support/concern'
require 'cached_resource/railtie' if defined?(Rails)
require 'cached_resource/cached_resource'
require 'cached_resource/configuration'
require 'cached_resource/metadata'
require 'cached_resource/caching'
require 'cached_resource/version'

module CachedResource
end

class ActiveResource::Base
  include CachedResource::Model
end
