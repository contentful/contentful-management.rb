# Change Log

## Master

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
