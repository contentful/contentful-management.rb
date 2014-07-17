# Contentful::Management

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'contentful-management'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install contentful-management

## Usage

```ruby
client = Contentful::Management::Client.new('71607c586050e66bdd6b14aef4515c8ea55034889336dac69c96cbd2c3916d08')

Contentful::Management::Space.all
space = Contentful::Management::Space.find('m0zubye23c17')
space.destroy

space = Contentful::Management::Space.new
space.name = 'GGG'
space.save

space = Contentful::Management::Space.create(name: 'GGG')
space.update(name: 'DDD')

space = Contentful::Management::Space.find('m0zubye23c17')
space.name = 'FFF'
space.save

space.content_types
space.content_types.all
space.content_types.find(id)
space.content_types.create(name: 'Test')
content_type = space.content_types.new
content_type.name = 'Name'
content_type.fields = [field_1, field_2]
content_type.save

content_type = space.content_types.find(id)
content_type.destroy
content_type.activate
content_type.deactivate
content_type.active?

field = Contentful::Management::Field.new
field.id = 'field_id'
field.name = 'Field Name'
field.type = 'Text'

content_type.update(name: 'Name', description: 'Description', fields: [field])
content_type.fields.create(id: 'field_id', name: 'Field Name', type: 'Text') #if field_id exists related field is updated
content_type.fields.add(field)
content_type.fields.destroy(field_id)

space.locales
space.locales.all
space.locales.find(id)
space.locales.create(params)

locale = space.locales.find(id)
locale.update(params)

space.assets
space.assets.all
asset = space.assets.find(id)

asset.destroy
asset.archive
asset.unarchive
asset.archived?
asset.unpublish
asset.publish
asset.published?

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/contentful-management/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
