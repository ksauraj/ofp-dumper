#!/usr/bin/env bash

merge_super() {
  # CC : @noobyysauraj (Github) / @Ksauraj (Telegram)
  if [ -f out/super.img ]; then echo "super.img already present, no need to merge" && return ; fi
  if [ -z "$1" ]; then
    # Run in interactive mode.
    if [ -f test_super.csv ]; then rm test_super.csv; fi
    cp $(find . -iname "super_map.csv") test_super.csv
    sed -i '1d' test_super.csv
    n_lines=$(wc -l test_super.csv | cut -d ' ' -f 1)
    echo "Select region to merge super images"
    echo "To make choice choose from 1 to $n_lines"
    echo "Default : 1"
    echo ""
    for i in $(seq 1 $n_lines ); 
    do 
        region=$(sed -n "${i}p" test_super.csv | cut -d ',' -f 2)
        echo $i : $region
    done
    read -rp "Select: " -t 10 -N 1 i_region # Wait 10 seconds for user input.
    echo ""
    if [ -z $i_region ]; then i_region=1; fi # If no response from user was given, then continue by merging default region.
    super_1=$(sed -n "${i_region}p" test_super.csv | cut -d ',' -f 3)
    super_2=$(sed -n "${i_region}p" test_super.csv | cut -d ',' -f 4)
    super_3=$(sed -n "${i_region}p" test_super.csv | cut -d ',' -f 5)
    echo "Merging super images for region $region : $super_1 $super_2 $super_3"
    cd out && simg2img "${super_1}" "${super_2}" "${super_3}" super.img && cd ..
    rm -v * >/dev/null # remove unwanted files from directory
    if [ -f test_super.csv ]; then rm test_super.csv; fi
  else
    # Run in non-interactive mode
    # Usage : merge_super <Region Codename>
    # Example : merge_super IN
    if [ -f test_super.csv ]; then rm test_super.csv; fi
    cp $(find . -iname "super_map.csv") test_super.csv
    i_region=$(grep -n $1 test_super.csv | cut -d ':' -f 1 | head -n1)
    if [ -z "$i_region" ]; then
      # Rerun script in interactive mode if specified region was not found.
      echo "Region $1 not found"
      echo "Executing script in interactive mode."
      echo ""
      merge_super
   else
      super_1=$(sed -n "${i_region}p" test_super.csv | cut -d ',' -f 3)
      super_2=$(sed -n "${i_region}p" test_super.csv | cut -d ',' -f 4)
      super_3=$(sed -n "${i_region}p" test_super.csv | cut -d ',' -f 5)
      echo "Merging super images : $super_1 $super_2 $super_3"
      cd out && simg2img "${super_1}" "${super_2}" "${super_3}" super.img && cd ..
      rm -v * >/dev/null # remove unwanted files from directory
    fi
    if [ -f test_super.csv ]; then rm test_super.csv; fi
  fi
  }

update_scatter() {
  for line_number in $(grep -n super.img $(find . -iname "*scatter*.txt" ) | cut -d ':' -f 1); do
    x_line=$(($line_number+1))
    sed -i ${x_line}s/false/true/ *scatter*.txt
  done
}


