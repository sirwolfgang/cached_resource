module CachedResource
  class Configuration
    attr_accessor :enabled, :collection_synchronization, :collection_arguments

    def initialize(options={})
      # If option not set, it will default to `nil`. A setting of `nil`
      # refers to global_configureation, allowing for class settings to
      # be overridden at runtime without inheritance concerns  
      @enabled = options[:enabled]
      @collection_synchronization = options[:collection_synchronization]
      @collection_arguments = options[:collection_arguments]
    end

    def enabled?
      return enabled unless enabled.nil?
      CachedResourceLibrary::global_configuration.enabled
    end

    def collection_synchronization?
      return collection_synchronization unless collection_synchronization.nil?
      CachedResourceLibrary::global_configuration.collection_synchronization
    end

    def observed_collection_arguments
      return collection_arguments unless collection_arguments.nil?
      CachedResourceLibrary::global_configuration.collection_arguments
    end
  end
end