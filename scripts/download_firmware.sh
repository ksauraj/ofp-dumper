#!/usr/bin/env bash

download_firmware() {
    aria2c -c -s16 -x16 "$OFP_LINK" 2>/dev/null || wget -q --show-progress "$OFP_LINK"
    if [ -f *.zip ]; then
        mkdir -p out
        unzip *.zip -d out && rm *.zip
        cp $(find . -name "*.ofp") ./
        rm -r */
        OFP_FILE=$(ls)
        OFPNAME=${OFPFILE%.*}
    elif [ -f *.7z ]; then
        7z x *.7z -y -oout && rm *.7z
        cp $(find . -name "*.ofp") ./
        rm -r */
        OFP_FILE=$(ls)
        OFPNAME=${OFPFILE%.*}
      elif [ -f *.ofp ]; then
        OFPFILE=${OFP_LINK##*/}
        OFP_FILE=${OFPFILE}
        OFPNAME=${OFPFILE%.*}
    else
        echo "Not correct firmware."
    fi
}
