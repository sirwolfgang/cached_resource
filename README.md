# CachedResource
`CachedResource` is designed as a minimal impact drop inplace caching layer for `ActiveResource`. All parts of `ActiveResource` are maintained so that the only changes to your existing codebase that are required to fully leverage the power of `CachedResource` is cache invalidation.

### Key Features
- _Just Works_ drop in place design
- Class & Global scoped configuration with live inheritance 
- Optimization of calls through collection based requests
- Shares internal metadata between potential application instances through cache

## Footprint
By default `CachedResource` is loaded into all `ActiveResource` classes and disabled. This means the following methods are added into your classes.
- Class
  - `find_with_cache` (`find_without_cache`)
  - `clear_cache`
  - `cache_configuration` (Read/Write)
  - `enable_cache`
  - `disable_cache`
  - `cache_enabled?`
- Instance
  - `clear_cache`
  - `cache_configuration` (Read Only)
  - `cache_enabled?`
  - `cache_key`
  - `cache_update` (Accepts Hash)

Internally `CachedResource` also uses the following Modules/Namespaces with the public library classes and interface listed below:
- `CachedResourceLibrary` (Private)
- `CachedResourceInterface` (Private)
- `CachedResource`
  - `Configuration` (Class)
  - `configuration` (Global Configuration Instance)
  - `enable`
  - `disable`
  - `enabled?`
  - `clear_cache`
  
## Configuration
Configurations may be set at both a global, gem wide, or per `ActiveResource` class. All settings on each class default to `nil`. When we encounter a `nil` setting, we defer the configuration to that of the current global settings. This means you can overide class based settings, but still toggle global caching with the `enable`/`disable` functionality as long as the class `enabled` setting is `nil`.

- `enabled`
  - Global Default: `false`
- `collection_synchronization`
  - Global Default: `false`
  - This setting enables the collection based optimzation layer. Rather then requesting just an instance, it will attempt to request an entire collection and update all retrive instances
- `collection_arguments`
  - Global Default: `[:all]`
  - This is the exploded arguments that return a collection. _Note: The metadata layer will add collections on the fly based on the activerecord return types_