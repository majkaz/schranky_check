#!/bin/bash

# ==============================================================================================================

# Merge collection times
# use file name to get the newest one in directory
# ==============================================================================================================
files=( POST_SCHRANKY_*.csv )
new=${files[${#files[@]}-1]}

# Konverze \r\n > \n a do utf8
# ==============================================================================================================
iconv -f cp1250 -t utf8 $new | dos2unix | 
# merge
# ==============================================================================================================

awk -F";" ' { 

# collection_times is in format 1 - Weekday, delete the unneeded text part
gsub (/ - [^;]*/,"")

# merge to post_box ref, join collection_times
a[$1":"$3]=a[$1":"$3] ? a[$1":"$3]"#"$12" "$11 : $12" "$11
} END { 
PROCINFO["sorted_in"]="@val_str_asc"
	for (i in a) {
		printf i";\""
		split(a[i],srt,"[#]*") 
		for (val in srt) 
			printf "%s",srt[val] (val>1?";":"")
			printf "\"\n"
	}
}' |

sort |
# replace wrong splits, delete last row (old header)
# ==============================================================================================================
sed 's/\( [0-9][0-9]\:[0-9][0-9]\)\([0-9]\)/\1;\2/g;s/;\"$/\"/;$ d' |

# replace day_nr > day
# ==============================================================================================================
sed 's/\([-";]\)1\([-" ]\)/\1Mo\2/g;s/\([-";]\)2\([-" ]\)/\1Tu\2/g;s/\([-";]\)3\([-" ]\)/\1We\2/g;s/\([-";]\)4\([-" ]\)/\1Th\2/g;s/\([-";]\)5\([-" ]\)/\1Fr\2/g;s/\([-";]\)6\([-" ]\)/\1Sa\2/g;s/\([-";]\)7\([-" ]\)/\1Su\2/g' |
# replace to tab separated
sed 's/;/\t/'> temp_cp

# get osm file
# ==============================================================================================================
# PBOX.query:
# area[name="Česko"];
# node[amenity=post_box][ref~"^[0-9][0-9][0-9][0-9][0-9]\:[0-9]+"](area);
# out meta;
# ==============================================================================================================
#wget -O PBOX.osm --post-file=PBOX.query "http://overpass-api.de/api/interpreter"
# osm > csv
# ==============================================================================================================
xmlstarlet sel -t -m //node -v './/tag[@k="ref"]/@v' -o "|" -v @lat -o "|" -v @lon -n PBOX.osm | 
tr "|" "\t" | sort | tee temp_osm |
#duplicates
uniq -d --check-chars=10  | cut -d$'\t' -f 1 > temp_dupl 
# remove duplicates from source
grep -v -f temp_dupl temp_cp > temp_source 
# join collection_times + coordinates
join -t$'\t' -j 1 temp_osm temp_source |
tee temp |
# remove duplicates;
#awk '!seen[$1]++' |
# create json
# body only
awk -F$'\t' '{print "{\n \"id\": \"" $1"\",\n \"lat\": "$2",\n \"lon\": "$3",\n \"tags\": {	\n  \"ref\": \""$1"\",\n  \"collection_times\" :"$4"\n  }\n},"}' |
# header + footer
sed -e 's/^/ /;1i[' -e '$c\ \} \n]' > PBOX.json

# change ref > ref:cp PBOX.osm > PBOXcp.osm
#sed 's/\"ref\"/\"ref:cp\"/' PBOX.osm > PBOXcp.osm

# remove duplicates from PBOX.osm
xmlstarlet fo -n PBOX.osm | tr "\n" "@" | sed 's/<\/node>@/<\/node>\n/g' | grep -v -f temp_dupl - | tr "@" "\n" | xmlstarlet fo -s 1 > PBOXnodup.osm

# conflate
conflate -i PBOX.json --osm PBOXnodup.osm -c PBOXout.json -o PBOXout.osm PBOX.profile.py
