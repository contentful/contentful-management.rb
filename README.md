# Contentful::Management

Ruby client for the Contentful Content Management API.

Contentful is a content management platform for web applications, mobile apps and connected devices. It allows you to create, edit & manage content in the cloud and publish it anywhere via powerful API. Contentful offers tools for managing editorial teams and enabling cooperation between organizations.

## Setup

Add this line to your application's Gemfile:

    gem 'contentful-management'

## Usage

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
blog_post_content_types = blog_space.content_types
```

or

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
blog_post_locales = blog_space.locales
```

or

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
blog_post_assets = blog_space.assets
```

or

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
entries = blog_space.entries
```

or

```ruby
entries = blog_space.entries.all
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


## Contributing

1. Fork it ( https://github.com/[my-github-username]/contentful-management/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
