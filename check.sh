#!/bin/bash  
# Poštovní schránky, test změn
# Očekává dva soubory POST_SCHRANKY_RRRRMM.csv, bez parametru načte první a poslední soubor POST_SCHRANKY_*.csv (podle jména) v adresáři

echo

if [ $# -eq 0 ]
	then
	files=( POST_SCHRANKY_*.csv )
	old=${files[0]}
	new=${files[${#files[@]}-1]}
	echo "OLD...$old"
	echo "NEW...$new"
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
		echo "OLD...$old"
		echo "NEW...$new"
	else
	echo "Očekávány 2 soubory POST_SCHRANKY_RRRRMM.csv nebo spuštění bez proměnných"
	exit 1
fi

echo
echo
echo "Změny u depa pošty:"
echo "--------------------------------------"
diff -u <(awk -F";" '!seen[$1";"$2]++ { print $1";"$2}' $old | sort -V) <(awk -F";" '!seen[$1";"$2]++ { print $1";"$2}' $new | sort -V) | \grep "^+\|^-"| sed 's/./& /;2d;1d' | tee Změny_depa.txt | tr ';' '\t'
echo "--------------------------------------"
wc -l Změny_depa.txt
echo "======================================"
sed -i -e '1iZměny u depa pošty mezi '$old' a '$new'\' Změny_depa.txt
echo

diff -u <(awk -F";" '!seen[$1";"$3]++ { print $1":"$3}' $old | sort -V) <(awk -F";" '!seen[$1";"$3]++ { print $1":"$3}' $new | sort -V) | \grep "^-\|^+" | sed 's/./& /;1,2d' | awk -F' ' '{print $2 > "Změny_ref_" ($1=="+" ? "přírůstky.txt" : "úbytky.txt")}'

echo "Změna ref schránky (přírůstky/úbytky):"
echo "--------------------------------------"
wc -l Změny_ref_přírůstky.txt 
wc -l Změny_ref_úbytky.txt 
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
wc -l Změny_doba_výběru.txt 
echo "======================================"
echo

sed -i -e '1iRef;'$old';'$new'\' Změny_doba_výběru.txt

# TODO:
# kontrola změny ref (přesuny mezi depy)
# sloučení podle sl. 4-10, hodnoty sl.1-3
# (sloučit čísla schránek < existuje více schránek na jedné adrese)
# nalezení rozdílů
# pokud byly čísla schránek sloučené a nalezen rozdíl, pokusit se rozdělit zpět a vyloučit totožné


# vymazání dočasných souborů
# rm tmp_???_CT.csv