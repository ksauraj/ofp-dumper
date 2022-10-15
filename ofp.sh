#!/usr/bin/env bash

source scripts/decrypt.sh
source scripts/download_firmware.sh
source scripts/extract_partitions.sh
source scripts/extract_super.sh
source scripts/merge_super.sh
source scripts/unknown_decrypt.sh


### Set Base Project Directory
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
if echo "${PROJECT_DIR}" | grep " "; then
	printf "\nProject Directory Path Contains Empty Space,\nPlace The Script In A Proper UNIX-Formatted Folder\n\n"
	sleep 1s && exit 1
fi

### Make New Directory.
rm -rf dumper
mkdir -p dumper && cd dumper

### Sanitize And Generate Folders
INPUTDIR="${PROJECT_DIR}"/input		# Firmware Download/Preload Directory
UTILSDIR="${PROJECT_DIR}"/utils		# Contains Supportive Programs
OUTDIR="${PROJECT_DIR}"/out			# Contains Final Extracted Files
TMPDIR="${OUTDIR}"/tmp
LPUNPACK="${UTILSDIR}"/lpunpack.py
ofp_mtk_decrypt="${UTILSDIR}"/ofp_mtk_decrypt.py
ofp_qc_decrypt="${UTILSDIR}"/ofp_qc_decrypt.py
EROFSFUSE="${UTILSDIR}"/erofsfuse

### Simple Vars
OFP_LINK="$1"
DTYPE="$2"
regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
string="$link"

### main function
main() {
        if [[ $string =~ $regex ]]; then
        download_firmware $1
        else
        echo "Copying Firmware"
        cp -v ../"$1" ${PROJECT_DIR}/dumper
        echo "Firmware copied..."
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

        fi
        if [ -z "$2" ]; then
            unknown_decrypt
        else
            decrypt
        fi
        merge_super
        extract_super
        extract_partitions
}

main

### EOF
