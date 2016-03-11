# Change Log

## Master

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
