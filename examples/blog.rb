###
# This should be and behave like a living example that grows with the code itself.
#

require 'pry'

access_token = 'dfc42ca5bc555ff4ed3aa5d8be57d1521e26ce9a730c30eca9aabb994fe18b9d'
organization = '6GKlfJHLqlvG52ncLqKNOm'

require 'contentful/management'

client = Contentful::Management::Client.new(access_token)

blog_space = Contentful::Management::Space.create(name: 'Blog', organization_id: organization)
# blog_space = Contentful::Management::Space.find('zlso53r1zad6')

blog_space.locales.create(name: 'English', code: 'en-US')
blog_space.locales.create(name: 'German', code: 'de-DE')

category_type = blog_space.content_types.create(name: 'Category')
category_type.fields.create(id: 'category_name', name: 'Category Name', type: 'Text', localized: true)
category_type.fields.create(id: 'category_description', name: 'Category Description', type: 'Text', localized: true)

post_type = blog_space.content_types.create(name: 'Post')
post_type.fields.create(id: 'post_title', name: 'Post Title', type: 'Text', localized: true)
post_type.fields.create(id: 'post_author', name: 'Post Author', type: 'Text', localized: true)
post_type.fields.create(id: 'post_body', name: 'Post Body', type: 'Text', localized: true)
post_type.fields.create(id: 'post_category', name: 'Post Category', type: 'Link', linkType: 'Entry', localized: true)

# category_type = blog_space.content_types.find('3bMvEx9ROwEQCmyGcYOI8c')
# post_type = blog_space.content_types.find('1D93omOM0YocSsGwY8wY6u')

post_type.activate
category_type.activate

sleep 10 # prevent race conditions
blog_space.destroy
