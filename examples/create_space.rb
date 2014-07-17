require 'pry'

access_token = 'dfc42ca5bc555ff4ed3aa5d8be57d1521e26ce9a730c30eca9aabb994fe18b9d'
organization = '6GKlfJHLqlvG52ncLqKNOm'

require 'contentful/management'

client = Contentful::Management::Client.new(access_token)

spaces = Contentful::Management::Space.all

my_space = Contentful::Management::Space.create(name: 'MySpace', organization_id: organization)

my_space.update(name: 'MyNewSpace')

dat_space = Contentful::Management::Space.find(my_space.id)


dat_space.locales.create(name: 'English', code: 'en-US')

locales = dat_space.locales
# locales.map(&:destroy) # not implemented yet?

dat_space.destroy


# XXX: This does not set the organization_id when a space should be created
#
your_space = Contentful::Management::Space.new
your_space.organization = organization
your_space.name = 'YourSpace'
your_space.save


your_space.destroy
