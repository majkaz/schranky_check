#!/bin/bash  
# Poštovní schránky, test změn
# Očekává dva soubory POST_SCHRANKY_RRRRMM.csv, bez parametru načte první a poslední soubor POST_SCHRANKY_*.csv (podle jména) v adresáři

# vymazání starých souborů změn
rm Změny*.txt

echo

if [ $# -eq 0 ]
	then
	files=( POST_SCHRANKY_*.csv )
	old=${files[0]}
	new=${files[${#files[@]}-1]}
elif [ $# -eq 2 ]
	then
		files=( $(sort <(printf "%s\n" "$@")) )
		old=${files[0]}
		new=${files[${#files[@]}-1]}
		if [ ! -e $old ]
		then
			echo "Soubor $old neexistuje"
			exit 1
		fi
		if [ ! -e $new ]
		then
			echo "Soubor $new neexistuje"
			exit 1
		fi
	else
	echo "Očekávány 2 soubory POST_SCHRANKY_RRRRMM.csv nebo spuštění bez proměnných"
	exit 1
fi

echo "Změny u depa pošty:"
echo "--------------------------------------"
diff -u <(awk -F";" '!seen[$1";"$2]++ { print $1";"$2}' $old | sort -V) <(awk -F";" '!seen[$1";"$2]++ { print $1";"$2}' $new | sort -V) | \grep "^+\|^-"| sed 's/./& /;2d;1d' | tee Změny_depa.txt | tr ';' '\t'

#num_of_lines=$(< "Změny_depa.txt" wc -l)

	if (( $(< "Změny_depa.txt" wc -l) > 0 ))
	then
		echo "--------------------------------------"
		wc -l Změny_depa.txt || echo "Beze změny mezi depy"
		echo "======================================"
		sed -i -e '1iZměny u depa pošty mezi '$old' a '$new'\' Změny_depa.txt
	else
		echo "Beze změny mezi depy"
		echo "======================================"
		rm Změny_depa.txt
	fi
echo

diff -u <(awk -F";" '!seen[$1";"$3]++ { print $1":"$3}' $old | sort -V) <(awk -F";" '!seen[$1";"$3]++ { print $1":"$3}' $new | sort -V) | \grep "^-\|^+" | sed 's/./& /;1,2d' | awk -F' ' '{print $2 > "Změny_ref_" ($1=="+" ? "přírůstky.txt" : "úbytky.txt")}'

echo "Změna ref schránky (přírůstky/úbytky):"
echo "--------------------------------------"
wc -l Změny_ref_přírůstky.txt || echo "Beze přírůstků" 
wc -l Změny_ref_úbytky.txt || echo "Beze úbytků" 
echo "======================================"

sed -i -e '1iMezi '$old' a '$new' přibyly schránky s ref:\' Změny_ref_přírůstky.txt
sed -i -e '1iMezi '$old' a '$new' ubyly schránky s ref:\' Změny_ref_úbytky.txt
echo

echo "...slučuji dobu výběru..."
echo 

sed '1cpsc;zkrnaz_posty;cis_schranky;adresa;sour_x;sour_y;misto_popis;cast_obce;obec;okres;cas;omezeni - omezeni' $old | ./collection_times.sh | sed 's/ @/;/' > tmp_old_CT.csv
sed '1cpsc;zkrnaz_posty;cis_schranky;adresa;sour_x;sour_y;misto_popis;cast_obce;obec;okres;cas;omezeni - omezeni' $new | ./collection_times.sh | sed 's/ @/;/'  > tmp_new_CT.csv

join -t";" -j 1 <(awk -F";" '{ print $1":"$3";"$11}' tmp_old_CT.csv | sort ) <(awk -F";" '{ print $1":"$3";"$11}' tmp_new_CT.csv | sort) | awk -F";" '$2!=$3' > Změny_doba_výběru.txt

echo "Změna doby výběru schránky:"
echo "--------------------------------------"
wc -l Změny_doba_výběru.txt || echo "Beze změny" 
echo "======================================"
echo

sed -i -e '1iRef;'$old';'$new'\' Změny_doba_výběru.txt

# kontrola změny ref (přesuny mezi depy)
# sloučení podle sl. 4-10, hodnoty sl.1-3
# (sloučit čísla schránek < existuje více schránek na jedné adrese)
echo ...kontrola podle adresy...
echo 

paste <(cut -d';' -f 4-10 tmp_old_CT.csv) <(cut -d';' -f 1-3 tmp_old_CT.csv) | awk -F$'\t' '{if(a[$1])a[$1]=a[$1]"|"$2; else a[$1]=$2;}END{for (i in a)print i, a[i];}' OFS="\t" | iconv -f cp1250 -t utf8 | sort > tmp_old_txt.txt
paste <(cut -d';' -f 4-10 tmp_new_CT.csv) <(cut -d';' -f 1-3 tmp_new_CT.csv) | awk -F$'\t' '{if(a[$1])a[$1]=a[$1]"|"$2; else a[$1]=$2;}END{for (i in a)print i, a[i];}' OFS="\t" | iconv -f cp1250 -t utf8 |sort > tmp_new_txt.txt
# nalezení rozdílů
join -t$'\t' -j 1 tmp_old_txt.txt tmp_new_txt.txt | awk -F$'\t' '$2!=$3 { print $2" > "$3 }'  |  sed 's/;[^;]*;/:/g' > Změny_změněná_ref.txt

echo "Změna ref schránky:"
echo "--------------------------------------"
wc -l Změny_změněná_ref.txt || echo "Beze změny"
echo "======================================"
echo
sed -i -e '1iRef '$old' > Ref '$new'\' Změny_změněná_ref.txt
# TODO:
# pokud byly čísla schránek sloučené a nalezen rozdíl, pokusit se rozdělit zpět a vyloučit totožné


# závěrečná informace a vymazání dočasných souborů
echo
echo "**************************************"
echo "Porovnávané soubory:"
echo "**************************************"
echo "OLD...$old"
echo "NEW...$new"
echo "**************************************"
echo "Změny byly uloženy v souborech:"
echo "**************************************"
ls -w1 Změny*.txt
echo "**************************************"

rm tmp_*.*