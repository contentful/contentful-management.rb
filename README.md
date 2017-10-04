# Contentful::Management
[![Gem Version](https://badge.fury.io/rb/contentful-management.svg)](http://badge.fury.io/rb/contentful-management) [![Build Status](https://travis-ci.org/contentful/contentful-management.rb.svg)](https://travis-ci.org/contentful/contentful-management.rb)

Ruby client for the Contentful Content Management API.

Contentful is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Setup

Add this line to your application's Gemfile:
```ruby
gem 'contentful-management'
```

## Usage

### Examples
Some examples can be found in the ```examples/``` directory or you take a look at this [extended example script](https://github.com/contentful/cma_import_script).

### Client

At the beginning the API client instance should be created for each thread that is going to be used in your application:

```ruby
require 'contentful/management'

client = Contentful::Management::Client.new('access_token')
```

The access token can easily be created through the [management api documentation](https://www.contentful.com/developers/documentation/content-management-api/#getting-started).

### Spaces

Retrieving all spaces:

```ruby
spaces = client.spaces.all
```

Retrieving one space by ID:

```ruby
blog_space = client.spaces.find('blog_space_id')
```

Destroying a space:

```ruby
blog_space.destroy
```

Creating a space:

```ruby
blog_space = client.spaces.new
blog_space.name = 'Blog Space'
blog_space.save
```

or

```ruby
blog_space = client.spaces.create(name: 'Blog Space')
```

or in the context of the organization (if you have multiple organizations within your account):

```ruby
blog_space = client.spaces.create(name: 'Blog Space', organization_id: 'organization_id')
```

If you want to create a default locale different from `en-US`:
```ruby
blog_space = client.spaces.create(name: 'Blog Space', default_locale: 'de-DE')
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

### Assets

Retrieving all assets from the space:

```ruby
blog_post_assets = blog_space.assets.all
```

Retrieving all published assets from the space: **DEPRECATED**

```ruby
blog_post_assets = blog_space.assets.all_published
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

Process an asset file after create:
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

### File Uploads

Creating an upload from a file path:

```ruby
upload = client.uploads.create('space_id', '/path/to/file.md')
```

Alternatively, create it from an `::IO` object:

```ruby
File.open('/path/to/file.md', 'rb') do |file|
  upload = client.uploads.create('space_id', file)
end
```

Finding an upload:

```ruby
upload = client.uploads.find('space_id', 'upload_id')
```

Deleting an upload:

```ruby
upload.destroy
```

Associating an upload with an asset:

```ruby
# We find or create an upload:
upload = client.uploads.find('space_id', 'upload_id')

# We create a File object with the associated upload:
file = Contentful::Management::File.new
file.properties[:contentType] = 'text/plain'
file.properties[:fileName] = 'file.md'
file.properties[:uploadFrom] = upload.to_link_json  # We create the Link from the upload.

# We create an asset with the associated file:
asset = client.assets.create('space_id', title: 'My Upload', file: file)
asset.process_file  # We process the file, to generate an URL for our upload.
```

### Entries

Retrieving all entries from the space:

```ruby
entries = blog_space.entries.all
```

Retrieving all published entries from the space: **DEPRECATED**

```ruby
entries = blog_space.entries.all_published
```

Retrieving all entries from the space with given content type:

```ruby
entries = blog_space.entries.all(content_type: content_type.id)
```

or

```ruby
entries = content_type.entries.all
```

Retrieving an entry by ID:

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

> Entries created with *empty fields*, will not return those fields in the response. Therefore, entries that don't have cache enabled, will need to
> make an extra request to fetch the content type and fill the missing fields.
> To allow for content type caching:
>   * Enable [content type cache](#content-type-cache) at client instantiation time
>   * Query entries through `space.entries.find` instead of `Entry.find(space_id, entry_id)`

### Content Types

Retrieving all content types from a space:

```ruby
blog_post_content_types = blog_space.content_types.all
```

Retrieving all published content types from a space:

```ruby
blog_post_content_types = blog_space.content_types.all_published
```

Retrieving one content type by ID from a space:

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

### Validations

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
blog_post_content_type.fields.create(id: 'valid', name: 'Test SIZE', type: 'Text', validations: [validation_size])
```

#### range

Takes optional min and max parameters and validates the range of a value.

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
blog_post_content_type.fields.create(id: 'entry', name: 'Test linkContentType', type: 'Entry', validations: [validation_link_content_type])
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

### Locales

Retrieving all locales from the space:

```ruby
blog_post_locales = blog_space.locales.all
```

Retrieving one locale by ID from the space:

```ruby
blog_post_locale = blog_space.locales.find(locale_id)
```

Creating a locale:

```ruby
blog_space.locales.create(name: 'German', code: 'de-DE')
```

Updating a locale:

```ruby
blog_post_locale.update(name: 'German', code: 'de-DE')
```

Destroying a locale:

```ruby
blog_post_locale.destroy
```

### Roles

Retrieving all roles from the space:

```ruby
blog_post_roles = blog_space.roles.all
```

Retrieving one role by ID from the space:

```ruby
blog_post_role = blog_space.role.find(role_id)
```

Creating a role:

```ruby
role_attributes = {
  name: 'My Role',
  description: 'foobar role',
  permissions: {
    'ContentDelivery': 'all',
    'ContentModel': ['read'],
    'Settings': []
  },
  policies: [
    {
      effect: 'allow',
      actions: 'all',
      constraint: {
        and: [
          {
            equals: [
              { doc: 'sys.type' },
              'Entry'
            ]
          },
          {
            equals: [
              { doc: 'sys.type' },
              'Asset'
            ]
          }
        ]
      }
    }
  ]
}
blog_space.roles.create(role_attributes)
```

Updating a role:

```ruby
blog_post_role.update(name: 'Some Other Role') # Can change any attribute here
```

Destroying a role:

```ruby
blog_post_role.destroy
```

### Webhooks

Retrieving all webhooks from the space:

```ruby
webhooks = blog_space.webhooks.all
```
Retrieving one webhook by ID from the space:

```ruby
blog_post_webhook = blog_space.webhooks.find(webhook_id)
```

Creating a webhook:

```ruby
blog_space.webhooks.create(
  name: 'My Webhook',
  url: 'https://www.example.com',
  httpBasicUsername: 'username',
  httpBasicPassword: 'password'
)
```

Updating a webhook:

```ruby
blog_post_webhook.update(url: 'https://www.newlink.com')
```

Destroying a webhook:

```ruby
blog_post_webhook.destroy
```

Creating a webhook with custom headers and custom topics:

```ruby
blog_space.webhooks.create(
  name: 'Entry Save Only',
  url: 'https://www.example.com',
  topics: [ 'Entry.save' ],
  headers: [
    {
      key: 'X-My-Custom-Header',
      value: 'Some Value'
    }
  ]
)
```

#### Webhook Calls

Retrieving all webhook call details from a webhook:

```ruby
all_call_details = my_webhook.webhook_calls.all
```
Retrieving one webhook call detail by ID from a webhook:

```ruby
call_details = my_webhook.webhook_calls.find(call_id)
```

#### Webhook Health

Retrieving webhook health details from a webhook:

```ruby
health_details = my_webhook.webhook_health.find
```

### Space Memberships

Retrieving all space memberships from the space:

```ruby
memberships = blog_space.space_memberships.all
```
Retrieving one space membership by ID from the space:

```ruby
blog_post_membership = blog_space.space_memberships.find(membership_id)
```

Creating a space membership:

```ruby
blog_space.space_memberships.create(
  admin: false,
  roles: [
    {
      'sys' => {
        'type' => 'Link',
        'linkType' => 'Role',
        'id' => 'my_role_id'
      }
    }
  ],
  email: 'foobar@example.com'
)
```

Updating a space membership:

```ruby
blog_post_membership.update(admin: true)
```

Destroying a space membership:

```ruby
blog_post_membership.destroy
```

#### Organizations

Retrieving all organization details:

```ruby
organizations = client.organizations.all
```

### UI Extensions

Retrieving all UI extensions from the space:

```ruby
extensions = blog_space.ui_extensions.all
```
Retrieving one UI extension by ID from the space:

```ruby
blog_post_extension = blog_space.ui_extensions.find(extension_id)
```

Creating a UI extension:

```ruby
blog_space.ui_extensions.create(
  extension: {
    'name' => 'My extension',
    'src' => 'https://www.example.com',
    'fieldTypes' => [{"type": "Symbol"}],
    'sidebar' => false
  }
)
```

Destroying a UI extension:

```ruby
blog_post_extension.destroy
```

### API Keys

Retrieving all API keys from the space:

```ruby
blog_post_api_keys = blog_space.api_keys.all
```

Retrieving one API key by ID from the space:

```ruby
blog_post_api_key = blog_space.api_keys.find(api_key_id)
```

Creating an API key:
```ruby
blog_space.api_keys.create(name: 'foobar key', description: 'key for foobar mobile app')
```

### Editor Interface

Retrieving editor interface for a content type:

```ruby
blog_post_editor_interface = blog_post_content_type.editor_interface.default
```

You can call the EditorInterface API from any level within the content model hierarchy, take into account that you'll need to
pass the IDs of the levels below it.

> Hierarchy is as follows:
> `No Object -> Space -> ContentType -> EditorInterface`

### Entry Snapshots

Retrieving all snapshots for a given entry:

```ruby
snapshots = entry.snapshots.all
```

Retrieving a snapshot for a given entry:

```ruby
snapshot = entry.snapshots.find('some_snapshot_id')
```

### Content Type Snapshots

Retrieving all snapshots for a given content type:

```ruby
snapshots = content_type.snapshots.all
```

Retrieving a snapshot for a given content type:

```ruby
snapshot = content_type.snapshots.find('some_snapshot_id')
```

### Pagination

```ruby
blog_space.entries.all(limit: 5).next_page
blog_space.assets.all(limit: 5).next_page
blog_space.entries.all(limit: 5).next_page
```

### Logging

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

### Raise Errors

If `:raise_errors` is set to true, an Exception will be raised in case of an error. The default is false, in this case a ```Contentful::Management::Error``` object will be returned.

```ruby
client = Contentful::Management::Client.new('access_token', raise_errors: true)
```

### Content Type Cache

This allows for fetching content types for your space at client instantiation time, which prevents extra requests per entry.
To enable this, in your client instantiation do:

```ruby
client = Contentful::Management::Client.new(token, dynamic_entries: ['my_space_id'])
```

You can enable the cache for as many spaces as you want. If no space is added, content types will be fetched upon space find.

To completely disable this feature, upon client instantiation do:

```ruby
client = Contentful::Management::Client.new(token, disable_content_type_caching: true)
```

### Proxy Support

This allows for using the CMA SDK through a proxy, for this, your proxy must support HTTPS and your server must have a valid signed certificate.

To enable this, in your client instantiation do:


```ruby
PROXY_HOST = 'localhost'
PROXY_PORT = 8888

# Just host/port
client = Contributing::Management::Client.new(
  token,
  proxy_host: PROXY_HOST,
  proxy_port: PROXY_PORT
)

# With username/password
client = Contributing::Management::Client.new(
  token,
  proxy_host: PROXY_HOST,
  proxy_port: PROXY_PORT,
  proxy_username: 'YOUR_USERNAME',
  proxy_password: 'YOUR_PASSWORD'
)
```

# Rate limit management

With the following configuration options you can handle how rate limits are handled within your applications.

## :max_rate_limit_retries

To increase or decrease the retry attempts after a 429 Rate Limit error. Default value is 1. Using 0 will disable retry behaviour.
Each retry will be attempted after the value (in seconds) of the `X-Contentful-RateLimit-Reset` header, which contains the amount of seconds until the next
non rate limited request is available, has passed. This is blocking per execution thread.

## :max_rate_limit_wait

Maximum time to wait for next available request (in seconds). Default value is 60 seconds. Keep in mind that if you hit the houly rate limit maximum, you
can have up to 60 minutes of blocked requests. It is set to a default of 60 seconds in order to avoid blocking processes for too long, as rate limit retry behaviour
is blocking per execution thread.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/contentful-management/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
