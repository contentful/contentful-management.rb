require 'pry'

access_token = 'access token'
organization = 'organization id'

require 'contentful/management'

client = Contentful::Management::Client.new(access_token)
space = Contentful::Management::Space.create(name: 'MySpace', organization_id: organization)

p space.content_types

type1 = space.content_types.create(name: 'ContentType 1')

p space.content_types.all

field = Contentful::Management::Field.new
field.id = 'such_content'
field.name = 'Such Content'
field.type = 'Text' # content types maybe as symbol?

type2 = space.content_types.new
type2.name = 'ContentType 2'
type2.fields = [field]
type2.save

field2 = Contentful::Management::Field.new
field2.id = 'wow_content'
field2.name = 'Wow Content'
field2.type = 'Location' # content types maybe as symbol?

type2.update(name: 'whoat', fields: [field, field2])

type2.fields.add(field2)

type2.activate
p type2.active?
type2.deactivate

type1.destroy

# clean up afterwards!
space.destroy
