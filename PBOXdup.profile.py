# Latest feed address
# download_url = 'http://...'
# What to write for the changeset's source tag
#source = 'CP:201810'
#add_source = False
# download ref only in bbox
#bounded_update = True
# ref:cp for joining
#dataset_id = 'cp'
# Use dataset_id
no_datased_id = True
find_ref = ''
# Overpass API query: [amenity="bicycle_rental"][network="Велобайк"]
#query = [('amenity', 'bicycle_rental'), ('network', 'Велобайк')]
query = [('amenity', 'post_box')]
# Maximum lookup radius is 100 meters
max_distance = 100
# Points that are not in the dataset should not be deleted
#delete_unmatched = False
# add disused for PBOX missing in the import file, add fixme tag
tag_unmatched = {
    'fixme': 'Zkontrolovat na místě, v souboru České pošty chybí',
    'amenity': None,
	'collection_times': None,
	'disused:amenity': 'post_box',
	'source': 'CP:201810'
}
# Overwriting these tags
master_tags = ('ref', 'operator', 'collection_times')
# Tag transformation
