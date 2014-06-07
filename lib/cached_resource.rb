require 'active_resource'
require 'active_support/concern'
require 'cached_resource/railtie' if defined?(Rails)
require 'cached_resource/cached_resource'
require 'cached_resource/interface'
require 'cached_resource/metadata'
require 'cached_resource/caching'
require 'cached_resource/version'

class ActiveResource::Base
  include CachedResource::Model
end
