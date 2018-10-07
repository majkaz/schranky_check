#
# check duplicates

curl https://overpass-api.de/api/interpreter\?data\=%5Bout%3Acsv%28%22ref%22%2C%3A%3Aid%29%5D%3Barea%5B%22name%22%3D%22%C4%8Cesko%22%5D%3B%28node%5B%22amenity%22%3D%22post%5Fbox%22%5D%5B%22ref%22%7E%22%5E%5B0%2D9%5D%7B5%7D%2E%2A%22%5D%28area%29%3B%29%3Bout%3B%0A | 
tr "\t" "," > ref.txt

csvpivot ref.txt --rows ref --values 'count(ref)' 'concat(@id)' | csvgrep -c 3 -r "[^1]" | 
# ignore 60010:000 duplicates for now
grep -v "60010:000" | grep \" | csvcut -c 2 | tr "\n" "," | tr -d \" | 
# prepare overpass query for import
sed "s/^/\narea[name="Česko"];\nnode\(id\:/;s/,$/\)\(area\);\nout meta;\n/"