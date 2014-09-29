###
# This should be and behave like a living example that grows with the code itself.
#
# TODO:
# - localisation
# - create links between posts and categories
# - link assets to posts
# - unpublish all posts
# - update assets
# - remove assets

require 'pry'

access_token = 'access token'
organization = 'organization id'

require 'contentful/management'

Contentful::Management::Client.new(access_token)

blog_space = Contentful::Management::Space.create(name: 'Blog', organization_id: organization)
# blog_space = Contentful::Management::Space.find('zlso53r1zad6')

blog_space.locales.create(name: 'English', code: 'en-US')
blog_space.locales.create(name: 'German', code: 'de-DE')

category_type = blog_space.content_types.create(name: 'Category')
category_type.fields.create(id: 'category_name', name: 'Category Name', type: 'Text', localized: true)
category_type.fields.create(id: 'category_description', name: 'Category Description', type: 'Text', localized: true)
category_type.update(displayField: 'category_name')

post_type = blog_space.content_types.create(name: 'Post')
post_type.fields.create(id: 'post_title', name: 'Post Title', type: 'Text', localized: true)
post_type.fields.create(id: 'post_author', name: 'Post Author', type: 'Text', localized: true)
post_type.fields.create(id: 'post_body', name: 'Post Body', type: 'Text', localized: true)
post_type.update(displayField: 'post_title')

categories = Contentful::Management::Field.new
categories.id = 'post_category'
categories.type = 'link'
categories.link_type = 'Entry'
post_type.fields.create(id: 'post_categories', name: 'Post Categories', type: 'Array', items: categories)

# category_type = blog_space.content_types.find('3bMvEx9ROwEQCmyGcYOI8c')
# post_type = blog_space.content_types.find('1D93omOM0YocSsGwY8wY6u')

post_type.activate
category_type.activate

sleep 10 # prevent race conditions

puts 'creating categories'
entries = []
entries << category_type.entries.create(category_name: 'Misc', category_description: 'Misc stuff')
entries << category_type.entries.create(category_name: 'Serious', category_description: 'Serious stuff')

# TODO: add links to categories
entries << post_type.entries.create(post_title: 'First Post', post_author: 'Andy', post_body: 'Letterpress sustainable authentic, disrupt semiotics actually kitsch. Direct trade Cosby sweater Austin, Pitchfork flexitarian small batch authentic roof party 8-bit YOLO literally Neutra pour-over American Apparel dreamcatcher. High Life distillery cliche YOLO, flexitarian four loko put a bird on it plaid Marfa Shoreditch seitan Echo Park bicycle rights Pinterest PBR. Drinking vinegar Banksy gastropub, stumptown occupy farm-to-table Blue Bottle tattooed Truffaut single-origin coffee iPhone locavore pug. Blue Bottle cray quinoa farm-to-table Bushwick tousled. Kitsch beard tousled, American Apparel XOXO vegan readymade Pitchfork church-key 3 wolf moon direct trade lo-fi. Food truck try-hard deep v salvia raw denim.', locale: 'en-US')
entries << post_type.entries.create(post_title: 'Second Post', post_author: 'Andy', post_body: "Fixie hashtag pour-over disrupt raw denim bespoke semiotics, typewriter Shoreditch messenger bag Thundercats chillwave DIY. Forage hoodie squid hella Kickstarter Thundercats, Banksy scenester flannel disrupt PBR&B fap chia. Small batch Brooklyn Williamsburg hella viral banh mi selfies organic. Semiotics Brooklyn skateboard cray messenger bag Echo Park. PBR&B High Life wolf meh, typewriter Bushwick VHS Cosby sweater mlkshk farm-to-table. Fingerstache readymade PBR literally, fixie letterpress swag fap. Authentic distillery banh mi, forage pork belly craft beer locavore DIY 90's iPhone 3 wolf moon synth.", locale: 'de-DE')

asset = blog_space.assets.new

asset.title_with_locales = {'en-US' => 'title picture 1', 'de-DE' => 'title picture 2'}
asset.description_with_locales = {'en-US' => 'space_asset_desc', 'de-DE' => 'space_asset_desc'}

file1 = Contentful::Management::File.new
file1.properties[:contentType] = 'image/jpeg'
file1.properties[:fileName] = 'pic1.jpg'
file1.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Gasometer_Berlin_Sch%C3%B6neberg_2011.jpg'

file2 = Contentful::Management::File.new
file2.properties[:contentType] = 'image/jpeg'
file2.properties[:fileName] = 'pic1.jpg'
file2.properties[:upload] = 'https://upload.wikimedia.org/wikipedia/commons/b/bd/Gasometer_Schoeneberg_innen.jpg'

asset.file_with_locales = {'en-US' => file1, 'de-DE' => file2}
asset.save

entries.map(&:publish)

puts 'Press any key to destroy space'
gets

blog_space.destroy
