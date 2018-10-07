no_datased_id = True
source='CP:201810'
dataset_id='cp'
find_ref = ''
query = [('amenity', 'post_box')]
max_distance = 70
tag_unmatched = {
    'fixme': 'Zkontrolovat na místě, v souboru České pošty chybí',
    'amenity': None,
	'collection_times': None,
	'disused:amenity': 'post_box',
	'source': 'CP:201810'
}
master_tags = ('ref', 'operator', 'collection_times')
transform = {
    'amenity': 'post_box',
	'operator': 'Česká pošta, s.p.',
}
