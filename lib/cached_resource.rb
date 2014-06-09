# lib/cached_resource.rb
require 'active_resource'
require 'active_support/concern'
require_relative 'cached_resource/cached_resource'
require_relative 'cached_resource/configuration'
require_relative 'cached_resource/version'
require_relative 'cached_resource/cached_resource_library'
require_relative 'cached_resource/cached_resource_library/railtie' if defined?(Rails)
require_relative 'cached_resource/cached_resource_library/cache'
require_relative 'cached_resource/cached_resource_library/cache/metadata'
require_relative 'cached_resource/cached_resource_interface/model'

module ActiveResource
  class Base
    include CachedResourceInterface::Model
  end
end
