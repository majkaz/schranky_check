 awk -F";" '
{
  PROCINFO["sorted_in"] = "@val_str_asc"
  printf $1";\""
  split($2,srt1,"[@]*") 
  for (val in srt1) printf "%s",(k++>2?";":"") srt1[val]
  printf "\";\""
  split($3,srt2,"[@]*") 
  for (val in srt2) printf "%s",(k++>2?";":"") srt2[val]
  printf "\"\n"
}'