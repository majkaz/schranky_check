source = 'CP:201810'
add_source = False
dataset_id = 'cp'
no_datased_id = True
find_ref = ''
query='[amenity=post_box][ref]'
tag_unmatched = {
    'fixme': 'Zkontrolovat na místě, v souboru České pošty chybí',
    'amenity': None,
	'note': None,
	'collection_times': None,
	'disused:amenity': 'post_box',
	'source': 'CP:201810'
}
master_tags = ('collection_times', 'source:collection_times', 'operator')
transform = {
    'amenity': 'post_box',
	'operator': 'Česká pošta, s.p.',
}
