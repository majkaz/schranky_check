#!/usr/bin/sh 
awk -F";"  '
    /.+/{
        split($12,a," - ")
		if (!($1";"$2";"$3";"$4";"$5";"$6";"$7";"$8";"$9";"$10 in Val)) { Key[++i] = $1";"$2";"$3";"$4";"$5";"$6";"$7";"$8";"$9";"$10}
        Val[$1";"$2";"$3";"$4";"$5";"$6";"$7";"$8";"$9";"$10] = Val[$1";"$2";"$3";"$4";"$5";"$6";"$7";"$8";"$9";"$10]"@"a[1]" "$11;
    }
    END{
        for (j = 1; j <= i; j++) {
            printf("%s %s\n%s", Key[j], Val[Key[j]], (j == i) ? "" : "");
        }
    }' 