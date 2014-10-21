
# Contentful::Management
[![Gem Version](https://badge.fury.io/rb/contentful-management.svg)](http://badge.fury.io/rb/contentful-management) [![Build Status](https://travis-ci.org/contentful/contentful-management.rb.svg)](https://travis-ci.org/contentful/contentful-management.rb)

# This Gem does not yet support the full API functionality.

Ruby client for the Contentful Content Management API.

Contentful is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Setup

Add this line to your application's Gemfile:

    gem 'contentful-management'

## Usage

### Examples
Some examples can be found in the ```examples/``` directory or you take a look at this [extended example script](https://github.com/contentful/cma_import_script).

### Client

At the beginning the API client instance should be created for each thread that is going to be used in your application:

```ruby
client = Contentful::Management::Client.new('access_token')
```

The access token can easily be created through the [management api documentation](https://www.contentful.com/developers/documentation/content-management-api/#getting-started).

### Spaces

Retrieving all spaces:

```ruby
spaces = Contentful::Management::Space.all
```

Retrieving one space by id:

```ruby
blog_space = Contentful::Management::Space.find('blog_space_id')
```

Destroying a space:

```ruby
blog_space.destroy
```

Creating a space:

```ruby
blog_space = Contentful::Management::Space.new
blog_space.name = 'Blog Space'
blog_space.save
```

or

```ruby
blog_space = Contentful::Management::Space.create(name: 'Blog Space')
```

or in the context of the organization (if you have multiple organizations within your account):

```ruby
blog_space = Contentful::Management::Space.create(name: 'Blog Space', organization_id: 'organization_id')
```

Updating a space:

```ruby
blog_space.update(name: 'New Blog Space')
```

or

```ruby
blog_space.name = 'New Blog Space'
blog_space.save
```

### Content Types

Retrieving all content types from a space:

```ruby
blog_post_content_types = blog_space.content_types.all
```

Retrieving one content type by id from a space:

```ruby
blog_post_content_type = blog_space.content_types.find(id)
```

Creating a field for a content type:

```ruby
title_field = Contentful::Management::Field.new
title_field.id = 'blog_post_title'
title_field.name = 'Post Title'
title_field.type = 'Text'
blog_post_content_type.fields.add(field)
```

or

```ruby
blog_post_content_type.fields.create(id: 'title_field_id', name: 'Post Title', type: 'Text')
```
- if the field_id exists, the related field will be updated.

or the field of link type:
```ruby
blog_post_content_type.fields.create(id: 'my_entry_link_field', name: 'My Entry Link Field', type: 'Link', link_type: 'Entry')
```

or the field of an array type:
```ruby
items = Contentful::Management::Field.new
items.type = 'Link'
items.link_type = 'Entry'
blog_post_content_type.fields.create(id: 'my_array_field', name: 'My Array Field', type: 'Array', items: items)
```

Deleting a field from the content type:

```ruby
blog_post_content_type.fields.destroy(title_field_id)
```

Creating a content type:

```ruby
blog_space.content_types.create(name: 'Post', fields: [title_field, body_field])
```

or

```ruby
blog_post_content_type = blog_space.content_types.new
blog_post_content_type.name = 'Post'
blog_post_content_type.fields = [title_field, body_field]
blog_post_content_type.save
```

Destroying a content type:

```ruby
blog_post_content_type.destroy
```

Activating or deactivating a content type:

```ruby
blog_post_content_type.activate
blog_post_content_type.deactivate
```

Checking if a content type is active:

```ruby
blog_post_content_type.active?
```

Updating a content type:

```ruby
blog_post_content_type.update(name: 'Post', description: 'Post Description', fields: [title_field])
```

### Locales

Retrieving all locales from the space:

```ruby
blog_post_locales = blog_space.locales.all
```

Retrieving one locale by the locale-id from the space:

```ruby
blog_post_locale = blog_space.locales.find(locale_id)
```

Creating a locale
```ruby
blog_space.locales.create(name: 'German', code: 'de-DE')
```

Updating a locale
```ruby
blog_post_locale.update(name: 'German', code: 'de-DE')
```

### Assets

Retrieving all assets from the space:


```ruby
blog_post_assets = blog_space.assets.all
```

Retrieving an asset by id:

```ruby
blog_post_asset = blog_space.assets.find('asset_id')
```

Creating a file:

```ruby
image_file = Contentful::Management::File.new
image_file.properties[:contentType] = 'image/jpeg'
image_file.properties[:fileName] = 'example.jpg'
image_file.properties[:upload] = 'http://www.example.com/example.jpg'
```

Creating an asset:

```ruby
my_image_asset = blog_space.assets.create(title: 'My Image', description: 'My Image Description', file: image_file)
```

or an asset with multiple locales

```ruby
my_image_localized_asset = space.assets.new
my_image_localized_asset.title_with_locales= {'en-US' => 'title', 'pl' => 'pl title'}
my_image_localized_asset.description_with_locales= {'en-US' => 'description', 'pl' => 'pl description'}
en_file = Contentful::Management::File.new
en_file.properties[:contentType] = 'image/jpeg'
en_file.properties[:fileName] = 'pic1.jpg'
en_file.properties[:upload] = 'http://www.example.com/pic1.jpg'
pl_file = Contentful::Management::File.new
pl_file.properties[:contentType] = 'image/jpeg'
pl_file.properties[:fileName] = 'pic2.jpg'
pl_file.properties[:upload] = 'http://www.example.com/pic2.jpg'
asset.file_with_locales= {'en-US' => en_file, 'pl' => pl_file}
asset.save
```

Process an Asset file after create:
```ruby
asset.process_file
```

Updating an asset:

- default locale

```ruby
my_image_asset.update(title: 'My Image', description: 'My Image Description', file: image_file)
```

- another locale (we can switch locales for the object, so then all fields are in context of selected locale)

```ruby
my_image_asset.locale = 'nl'
my_image_asset.update(title: 'NL Title', description: 'NL Description', file: nl_image)
```

- field with multiple locales

```ruby
my_image_asset.title_with_locales = {'en-US' => 'US Title', 'nl' => 'NL Title'}
my_image_asset.save
```

Destroying an asset:

```ruby
my_image_asset.destroy
```

Archiving or unarchiving an asset:

```ruby
my_image_asset.archive
my_image_asset.unarchive
```

Checking if an asset is archived:

```ruby
my_image_asset.archived?
```

Publishing or unpublishing an asset:

```ruby
my_image_asset.publish
my_image_asset.unpublish
```

Checking if an asset is published:

```ruby
my_image_asset.published?
```

### Entries

Retrieving all entries from the space:

```ruby
entries = blog_space.entries.all
```

Retrieving all entries from the space with given content type:

```ruby
entries = blog_space.entries.all(content_type_id: content_type.id)
```

or

```ruby
entries = content_type.entries.all
```

Retrieving an entry by id:

```ruby
entry = blog_space.entries.find('entry_id')
```

Creating a location:

```ruby
location = Location.new
location.lat = 22.44
location.lon = 33.33
```

Creating an entry:
- with a default locale

```ruby
my_entry = blog_post_content_type.entries.create(post_title: 'Title', assets_array_field: [image_asset_1, ...], entries_array_field: [entry_1, ...], location_field: location)
```

- with multiple locales

```ruby
my_entry = blog_post_content_type.entries.new
my_entry.post_title_with_locales = {'en-US' => 'EN Title', 'pl' => 'PL Title'}
my_entry.save
```

Updating an entry:
- with a default locale

```ruby
my_entry.update(params)
```

- with another locale
```ruby
entry.locale = 'nl'
entry.update(params)
```

- with multiple locales

```ruby
my_entry.post_title_with_locales = {'en-US' => 'EN Title', 'pl' => 'PL Title'}
my_entry.save
```

Destroying an entry:

```ruby
my_entry.destroy
```

Archiving or unarchiving the entry:

```ruby
my_entry.archive
my_entry.unarchive
```

Checking if the entry is archived:

```ruby
my_entry.archived?
```

Publishing or unpublishing the entry:

```ruby
my_entry.publish
my_entry.unpublish
```

Checking if the entry is published:

```ruby
my_entry.published?
```

### Webhooks

Retrieving all webhooks from the space:

```ruby
webhooks = blog_space.webhooks.all
```
Retrieving one webhook by the webhook-id from the space:

```ruby
blog_post_webhook = blog_space.webhooks.find(webhook_id)
```

Creating a webhook

```ruby
blog_space.webhooks.create(url: 'https://www.example.com', httpBasicUsername: 'username', httpBasicPassword: 'password')
```

Updating a webhook

```ruby
blog_post_webhook.update(url: 'https://www.newlink.com')
```

Destroying webhook:

```ruby
blog_post_webhook.destroy
```

## Validations

#### in

Takes an array of values and validates that the field value is in this array.

```ruby
validation_in = Contentful::Management::Validation.new
validation_in.in = ['foo', 'bar', 'baz']
blog_post_content_type.fields.create(id: 'valid', name: 'Testing IN', type: 'Text', validations: [validation_in])
```

#### size

Takes optional min and max parameters and validates the size of the array (number of objects in it).

```ruby
validation_size = Contentful::Management::Validation.new
validation_size.size = { min: 10, max: 15 }
blog_post_content_type.fields.create(id: 'valid', name: 'Test In', type: 'Text', validations: [validation_size])
```

#### range

Takes a string that reflects a JS regex and flags, validates against a string. See JS Reference for the parameters.

```ruby
validation_range = Contentful::Management::Validation.new
validation_range.range = { min: 100, max: 150 }
blog_post_content_type.fields.create(id: 'valid', name: 'Range', type: 'Text', validations: [validation_range])
```

#### regex

Takes a string that reflects a JS regex and flags, validates against a string. See [JS Reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp) for the parameters.

```ruby
validation_regexp = Contentful::Management::Validation.new
validation_regexp.regexp = {pattern: '^such', flags: 'im'}
blog_post_content_type.fields.create(id: 'valid', name: 'Regex', type: 'Text', validations: [validation_regexp])
```

#### linkContentType

Takes an array of content type ids and validates that the link points to an entry of that content type.

```ruby
validation_link_content_type = Contentful::Management::Validation.new
validation_link_content_type.link_content_type =  ['post_content_type_id']
blog_post_content_type.fields.create(id: 'entry', name: 'Regex', type: 'Entry', validations: [validation_link_content_type])
```

#### linkMimetypeGroup

Takes a MimeType group name and validates that the link points to an asset of this group.

```ruby
validation_link_mimetype_group = Contentful::Management::Validation.new
validation_link_mimetype_group.link_mimetype_group = 'image'
content_type.fields.create(id: 'asset', validations: [validation_link_mimetype_group])
```

#### present

Validates that a value is present.

```ruby
validation_present = Contentful::Management::Validation.new
validation_present.present = true
content_type.fields.create(id: 'number', validations: [validation_present])
```

#### linkField

Validates that the property is a link (must not be a valid link, just that it looks like one).

```ruby
validation_link_field = Contentful::Management::Validation.new
validation_link_field.link_field  = true
content_type.fields.create(id: 'entry', validations: [validation_link_field])
```

### Pagination

```ruby
blog_space.entries.all(limit: 5).next_page
blog_space.assets.all(limit: 5).next_page
blog_space.entries.all(limit: 5).next_page
``` 

## Logging

Logging is disabled by default, it can be enabled by setting a logger instance and a logging severity.

```ruby
client = Contentful::Management::Client.new('access_token', logger: logger_instance, log_level: Logger::DEBUG)
```

Example loggers:

```ruby
Rails.logger
Logger.new('logfile.log')
```

The default severity is set to INFO and logs only the request attributes (headers, parameters and url). Setting it to DEBUG will also log the raw JSON response.

## Proxy

To make request behind proxy, you need to specify ```:post_host``` it might be domain or IP address of your proxy server and port number that is used by the proxy server for client connections.

```ruby
client = Contentful::Management::Client.new(
  'access_token',
   proxy_host: 'proxy-domain',
   proxy_port: 8080,
)
```

### Proxy with authentication

To use proxy with authentication, you need to specify ```proxy_username``` and ```proxy_password``` parameters.

```ruby
client = Contentful::Management::Client.new(
  'access_token',
  proxy_host: 'proxy-domain',
  proxy_port: 8080,
  proxy_username: 'username',
  proxy_password: 'secret_password',
)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/contentful-management/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
