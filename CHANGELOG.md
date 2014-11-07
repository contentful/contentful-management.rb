# Change Log

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
* Fix: Use array for symbols in entry fields

## 0.2.0
### Fixed
* Fix: create entry with multiple locales, skip attributes for not localized fields in content types
* Fix: reload Assets

### Added
* Add optional gzip encoding

## 0.1.0
### Added
* Support for web hooks
* Image url to asset

### Fixed
* Fix: remove implicit processing of assets.
* Fix: Gem is modifying nil #17
* Fix: rename asset.process_files to asset.process

### Other
* Cleaning code

## 0.0.3
### Added:
* More documentation

### Fixed:
* Fix: next_page feature
* Fix: create entry with specific locale
* Fix: service unavailable error (503)
* Fix: reload method on objects
### Other
* Code cleanup

## 0.0.2
### Fixed
* Fix: Convert an Entry to a DynamicEntry after being created.

## 0.0.1
### Added
* Adding rdoc
* Adding filter by content_type id

### Fixed
* Fix: Headers not properly cleared between requests
* Fix: Create entries with custom identifier

### Other
* Code cleanup

## 0.0.1-pre
* alpha pre-release
