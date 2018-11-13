# Change Log

## Master

## 2.6.0
### Added
* Added Usage Periods API.
* Added API Usages API.

## 2.5.0

As `RichText` moves from `alpha` to `beta`, we're treating this as a feature release.

### Added
* Added `#save` method to resources, generalizing how to create/update them.

### Changed
* Renamed `StructuredText` to `RichText`.

## 2.4.0
### Added
* Added support for StructuredText field type.

## Master
### 2.3.0
* Added `transformation` and `filters` to `Webhook`.
* Added `parameters` to `UIExtension.extension`.

### Fixed
* `#reload` now works with `Environment` objects.
* Fixed URL generation for `/users` endpoint.
* Fixed Space Memberships now properly forward all attributes.

### Changed
* Simplified asset creation process - this change doesn't affect functionality, but removes a couple of steps and provides equivalent functionality.

## 2.2.2
### Fixed
* Fixed URL generation for `/organizations` endpoint.

### Changed
**BREAKING CHANGES**:
* `nil` values on localized entries now no longer fallback to the default locale value when reading them. [#164](https://github.com/contentful/contentful-management.rb/issues/164)

## 2.2.1
### Fixed
* Fixed side-effect that was causing entries created using `content_type.entries.new` to fail to save.

## 2.2.0
### Added
* Added `#save` as a shortcut for `editor_interface.update(controls: editor_interface.controls)`. [#155](https://github.com/contentful/contentful-management.rb/issues/155)

## 2.1.1
### Fixed
* Fixed query parameter forwarding when querying from an environment proxy. [#160](https://github.com/contentful/contentful-management.rb/issues/160)

## 2.1.0
### Added
* Added environment selection option for Api Keys.
* Added a way to obtain Preview Api Keys.

### Fixed
* Fixed `Link#resolve` not working for all resource types.

## 2.0.2
### Fixed
* Fixed environment ID fetching for environment aware resources.

## 2.0.1
### Fixed
* Fixed environment proxy `find` method.

## 2.0.0
### Added
* Added support for Environments.

### Changed

**BREAKING CHANGES**:
* In order to provide a better top-level client API, `space_id` and `environment_id`, are now sent on the resource proxy call, rather than on the call itself. This allows for better reusability of proxies, which in the end provide a better developer experience.
Resources that are not environment-aware, still have the parameter arrangement changed, so proxies are also reusable, but do not include `environment_id`.
The `spaces`, `users`, `organizations` and `personal_access_tokens` proxies still do not require any parameters as they are top level resources.

Before (this code will assume that the old code was also environment aware, so that the impact is more visible):

```ruby
# Fetching all entries
client.entries.all(space_id, environment_id)

# Fetching a single entry
client.entries.find(space_id, environment_id, entry_id)

# If you wanted to find another entry, you'd have to repeat `space_id` and `environment_id`
client.entries.find(space_id, environment_id, another_entry_id)
```

Now:

```ruby
# Fetching all entries
client.entries(space_id, environment_id).all

# Fetching a single entry
entries_proxy = client.entries(space_id, environment_id)
entries_proxy.find(entry_id)

# If you wanted to find another entry, you just reuse the resource proxy
entries_proxy.find(another_entry_id)
```

The proxies, apart from the parameter re-shuffling, have kept the same interface.

* Spaces do no longer have proxies for `entries`, `assets`, `content_types`, `ui_extensions`, `locales` and `editor_interfaces`. These can now be found under `environments`.
* Space objects now have `environments` as a proxy accessor.
* Content Type Caching is now done when requesting Content Types, or when a property is missing on an Entry. Also `dynamic_entries` has been updated to receive a hash of `space_id => environment_id` pairs.

### Removed

* `all_published` methods for Entries and Assets have been removed.

## 1.10.1
### Fixed
* Fixed an error when calling next page on `Contentful::Array` that came from requests without query parameters. [#143](https://github.com/contentful/contentful-management.rb/issues/143)
* Fixed an issue with sending `default` on newly created locales.

### Added
* Added option to add a `fallback_code` when creating locales.

## 1.10.0
### Added
* Added better error messages for all possible API errors [#95](https://github.com/contentful/contentful-management.rb/issues/95)

## 1.9.0
### Added
* Added option to disable Content Type caching completely.
* Added UI Extension Endpoint.
* Added Space Memberships Endpoint.
* Added Webhook Calls Endpoint.
* Added Webhook Health Endpoint.
* Added Content Type Snapshots Endpoint.
* Added Organizations Endpoint.
* Added User Endpoint.
* Added Personal Access Tokens Endpoint.

### Changed
* Rewrote HTTP internals in order to allow base-level resources and simplified Client.

## 1.8.1
### Added
* Added missing validation property for assets [#121](https://github.com/contentful/contentful-management.rb/pull/121)

## 1.8.0
### Added
* Added `X-Contentful-User-Agent` header for more information.

## 1.7.0

### Added
* Added support for Upload API

## 1.6.0

### Added
* Added support for Snapshot API

## 1.5.0
### Added
* Added support for Select Operator in Entries and Assets

## 1.4.0
### Added
* Added support for Fallback Locales (`nil` values get now removed from the requests on `#update` and `#create`)

## 1.3.0
### Added
* Added Rate Limit automatic handling

## 1.2.0
### Added
* Add support for `::Contentful::Entry` and `::Contentful::Asset` serialization when using the CDA SDK along side this client [#105](https://github.com/contentful/contentful-management.rb/pull/105)
* Add `:optional` property to Locale

## 1.1.0
### Added
* Add Roles and Permissions Support
* Add Headers, Topics and Webhook Name Support
* Add Editor Interfaces Support
* Add `:omitted` property to Content Type Fields

### Changed
* Added Deprecation warning for `assets.all_published` and `entries.all_published`. This methods will be completely removed soon.

## 1.0.1
### Changed
* Changed locale selection priority when requesting fields [#91](https://github.com/contentful/contentful-management.rb/issues/91)

## 1.0.0
### Breaking Changes
* `Client` is no longer a singleton. Therefore all `Resource` class calls (`Entry`, `Space`, `ContentType`, etc...) require an instance of a client.
  The Client needs to be the first parameter of the call. As sending the client in every call is not a great solution, a shorthand for every resource
  class is present on the client. Calls can be done now like: `client.entries.all`. This works for every resource class, and all of the calls existing previously
  (`all`, `find`, `create`, `all_published`). **Note: `all_published` is specific to `Entry`, `Asset` and `ContentType`**.
* You can have as many instances of client, for as many users as you want.

Complete List of resource links on `Client`:
* `#entries`
* `#assets`
* `#spaces`
* `#content_types`
* `#locales`
* `#webhooks`
* `#api_keys`

### Fixed

* Removed code duplication between FieldAware and DynamicEntry [#78](https://github.com/contentful/contentful-management.rb/issues/78)
* Refactored FieldAware code to be simplified

### Added

* Proxy Support [#88](https://github.com/contentful/contentful-management.rb/issues/88)

## 0.9.0
### Added
* Added `#destroy` method to Locales
* Added `ApiKey` class, methods and `Space` associations
* Added `.all_published` methods for `ContentType`, `Asset` and `Entry`
* Locales can now update `:code` value

### Changed
* Changed documentation format to YARD

## 0.8.0
### Added
* Added `:dynamic_entries` parameter on Client initialization
* Added `FieldAware` for Entries that don't have complete fields

### Fixed
* Fixed `nil` fields on Content Types no longer sent to API [#79](https://github.com/contentful/contentful-management.rb/issues/79)

## 0.7.3
### Fixed
* Field names are no longer dependent on being present on `default_locale` [#70](https://github.com/contentful/contentful-management.rb/issues/70)


## 0.7.2
### Fixed
* Ensure that `Validation.type` returns correct value [#59](https://github.com/contentful/contentful-management.rb/issues/59), [#66](https://github.com/contentful/contentful-management.rb/issues/66)
* Ensure that already existing `Space` returns correct `Locale` for `#default_locale` [#60](https://github.com/contentful/contentful-management.rb/issues/60)
* Remove unintended nested `Validation` [#49](https://github.com/contentful/contentful-management.rb/issues/49)


## 0.7.1
### Fixed
* `fields_for_query` should only skip `nil` values [#63](https://github.com/contentful/contentful-management.rb/issues/63), [#64](https://github.com/contentful/contentful-management.rb/pull/64)
* Reinstate support for simple assignments to fields [#61](https://github.com/contentful/contentful-management.rb/issues/61), [#62](https://github.com/contentful/contentful-management.rb/pull/62)
* Fix NULL/nil handling for entries [#65](https://github.com/contentful/contentful-management.rb/pull/65)


## 0.7.0
### Added
* Add disable property to fields [#50](https://github.com/contentful/contentful-management.rb/pull/50), [#55](https://github.com/contentful/contentful-management.rb/pull/55)

### Fixed
* Explicitly set displayField to nil when it is not existing [#53](https://github.com/contentful/contentful-management.rb/pull/53), [#54](https://github.com/contentful/contentful-management.rb/pull/54)
* Merge values for default locale and current locale [#58](https://github.com/contentful/contentful-management.rb/pull/58)


## 0.6.1
### Fixed
* Fix access to space default_locale instance variable [#47](https://github.com/contentful/contentful-management.rb/pull/47)
* Better handling of 503 responses from the API [#48](https://github.com/contentful/contentful-management.rb/pull/48)
* Do Not loose displayField on update when it is not set [#52](https://github.com/contentful/contentful-management.rb/pull/52)


## 0.6.0
### Added
* Access request and response from Contentful::Management:Error [#46](https://github.com/contentful/contentful-management.rb/pull/46)

### Fixed
* Handle 429 responses as errors [#46](https://github.com/contentful/contentful-management.rb/pull/46)


## 0.5.0
### Added
* Allow setting a default locale when creating a space [#43](https://github.com/contentful/contentful-management.rb/pull/43)

### Fixed
* Handle `UnprocessableEntity` (HTTP 422) as its own error. [#42](https://github.com/contentful/contentful-management.rb/pull/42)


## 0.4.1
### Fixed
* Handle 409 responses as errors [#39](https://github.com/contentful/contentful-management.rb/pull/39)

## 0.4.0
### Fixed
* Return Keep attribute if it's already a hash [#33](https://github.com/contentful/contentful-management.rb/pull/33)
* Typo in header [#34](https://github.com/contentful/contentful-management.rb/pull/34)
* Items are nil when creating an array field for a content type [#35](https://github.com/contentful/contentful-management.rb/issues/35)

### Added
* `raise_errors` can be enabled, disabled by default [#38](https://github.com/contentful/contentful-management.rb/pull/38)


## 0.3.1
### Added
* Logging of requests
* Access to validations in responses
* Create validations through the API

### Fixed
* Cleaner and better error handling

### Other
* Cleaned the code
* Remove encoding strings from the source code files


## 0.2.1
### Fixed
* Use array for symbols in entry fields


## 0.2.0
### Fixed
* create entry with multiple locales, skip attributes for not localized fields in content types
* reload Assets

### Added
* Add optional gzip encoding


## 0.1.0
### Added
* Support for web hooks
* Image url to asset

### Fixed
* remove implicit processing of assets.
* Gem is modifying nil #17
* rename asset.process_files to asset.process

### Other
* Cleaning code


## 0.0.3
### Added:
* More documentation

### Fixed:
* next_page feature
* create entry with specific locale
* service unavailable error (503)
* reload method on objects

### Other
* Code cleanup


## 0.0.2
### Fixed
* Fix: Convert an Entry to a DynamicEntry after being created.


## 0.0.1
### Added
* rdoc
* filter by content_type id

### Fixed
* Headers not properly cleared between requests
* Create entries with custom identifier

### Other
* Code cleanup


## 0.0.1-pre
* alpha pre-release
