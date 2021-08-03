#!/bin/bash

for i  in *md
do 
LINE=$(cat $i | grep -v ^--- | grep -v ^title | head -1 | cut -d ' ' -f2- | sed 's/^ //')
printf "  - ${LINE}: "
printf "'%s '\n" "${i}"
done
