#!/usr/bin/env bash

source scripts/decrypt.sh
source scripts/download_firmware.sh
source scripts/extract_others.sh
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
OUTDIR="${PROJECT_DIR}"/dumper/work			# Contains Final Extracted Files
TMPDIR="${OUTDIR}"/tmp
SDAT2IMG="${UTILSDIR}"/sdat2img.py
SIMG2IMG="${UTILSDIR}"/bin/simg2img
PACKSPARSEIMG="${UTILSDIR}"/bin/packsparseimg
UNSIN="${UTILSDIR}"/unsin
PAYLOAD_EXTRACTOR="${UTILSDIR}"/bin/payload-dumper-go
DTB_EXTRACTOR="${UTILSDIR}"/extract-dtb.py
DTC="${UTILSDIR}"/dtc
VMLINUX2ELF="${UTILSDIR}"/vmlinux-to-elf/vmlinux-to-elf
KALLSYMS_FINDER="${UTILSDIR}"/vmlinux-to-elf/kallsyms-finder
OZIPDECRYPT="${UTILSDIR}"/oppo_ozip_decrypt/ozipdecrypt.py
OFP_QC_DECRYPT="${UTILSDIR}"/oppo_decrypt/ofp_qc_decrypt.py
OFP_MTK_DECRYPT="${UTILSDIR}"/oppo_decrypt/ofp_mtk_decrypt.py
OPSDECRYPT="${UTILSDIR}"/oppo_decrypt/opscrypto.py
SPLITUAPP="${UTILSDIR}"/splituapp.py
PACEXTRACTOR="${UTILSDIR}"/pacextractor/python/pacExtractor.py
NB0_EXTRACT="${UTILSDIR}"/nb0-extract
KDZ_EXTRACT="${UTILSDIR}"/kdztools/unkdz.py
DZ_EXTRACT="${UTILSDIR}"/kdztools/undz.py
RUUDECRYPT="${UTILSDIR}"/RUU_Decrypt_Tool
EXTRACT_IKCONFIG="${UTILSDIR}"/extract-ikconfig
UNPACKBOOT="${UTILSDIR}"/unpackboot.sh
AML_EXTRACT="${UTILSDIR}"/aml-upgrade-package-extract
AFPTOOL_EXTRACT="${UTILSDIR}"/bin/afptool
RK_EXTRACT="${UTILSDIR}"/bin/rkImageMaker
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
        install_external_tools
	extract_others
}

main $1 $2

### EOF
