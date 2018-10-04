# Latest feed address
# download_url = 'http://...'
# What to write for the changeset's source tag
source = 'CP:201810'
add_source = False
# ref:cp for joining
dataset_id = 'cp'
# Use dataset_id
no_datased_id = True
find_ref = ''
# Overpass API query: [amenity="post_box"][ref]
query='[amenity=post_box][ref]'
# Maximum lookup radius is 10 meters, shouldn't be needed, the position is taken from OSM
# Points that are not in the dataset should not be deleted
# delete_unmatched = False
# add disused for PBOX missing in the import file, add fixme tag
tag_unmatched = {
    'fixme': 'Zkontrolovat na místě, v souboru České pošty chybí',
    'amenity': None,
	'note': None,
	'collection_times': None,
	'disused:amenity': 'post_box',
	'source': 'CP:201810'
}
# Overwriting these tags
master_tags = ('collection_times', 'source:collection_times', 'operator')
# Tag transformation
transform = {
    'amenity': 'post_box',
#	'source:collection_times': 'CP:201810',
	'operator': 'Česká pošta, s.p.',
#	'note': '-',
}
