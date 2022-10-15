#!/usr/bin/env bash

download_firmware() {
        aria2c -c -s16 -x16 "$OFP_LINK" 2>/dev/null || wget -q --show-progress "$OFP_LINK"
        if [ -f *.zip ]; then
            unzip *.zip && rm *.zip
            cp */*.ofp ./
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
