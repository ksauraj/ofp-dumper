#!/usr/bin/env bash

source scripts/board_info.sh
source scripts/decrypt.sh
source scripts/download_firmware.sh
source scripts/extract_others.sh
source scripts/extract_partitions.sh
source scripts/extract_super.sh
source scripts/merge_super.sh
source scripts/push_gitlab.sh
source scripts/push_github.sh
source scripts/unknown_decrypt.sh
source scripts/tg-utils.sh

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
OUTDIR="${PROJECT_DIR}"/dumper/work			# Contains Extracted Files, later all files move to DUMPER_DIR
DUMPER_DIR="${PROJECT_DIR}"/dumper			# Contains Final Extracted Files
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
EROFSFUSE="${UTILSDIR}"/erofsfuse
ofp_mtk_decrypt="${UTILSDIR}"/ofp_mtk_decrypt.py
ofp_qc_decrypt="${UTILSDIR}"/ofp_qc_decrypt.py

### Simple Vars
OFP_LINK="$1"
DTYPE="$2"
regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
string="$OFP_LINK"

### main function
main() {
        if [[ $string =~ $regex ]]; then
            
            tg --sendmsg "$BOT_CHAT_ID" "Downloading Firmware"  
            download_firmware $1
        else
            echo "Copying Firmware"
            tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Copying Firmware."
            ln -v ../"$1" ${PROJECT_DIR}/dumper/"$(basename "$1")"
            #cp -v ../"$1" ${PROJECT_DIR}/dumper
            echo "Firmware copied..."
            tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Firmware copied."
            if [ -f *.zip ] || [ -f *.7z ]; then
               7za x *.zip -mmt$(nproc --all) || 7za x *.7z -mmt$(nproc --all) && rm *.zip *.7z -fv
                cp */*.ofp ./    
                if [ -f */*.csv ]; then
                  cp */*.csv ./
                fi
                rm -r */
                OFP_FILE=$(find . -iname '*.ofp')
                OFPNAME=${OFPFILE%.*}
            elif [ -f *.ofp ]; then
                OFPFILE=${OFP_LINK##*/}
                OFP_FILE=${OFPFILE}
                OFPNAME=${OFPFILE%.*}
            else
                echo "Invalid firmware."
                tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Invalid Firmware."
            fi

        fi
        if [ -z "$2" ]; then
            tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Trying Blind Decryption."
            unknown_decrypt
        else
            tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Decrypting OFP."
            decrypt
        fi

        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Merging Super."
        merge_super
        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Extrcating Super."
        extract_super
        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Extracting Partitions"
        extract_partitions
        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Installing External Tools"
        install_external_tools
        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Extract other partitions"
        extract_others
        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Create Board-info.txt"
        board_info
        tg --editmsg "$BOT_CHAT_ID" "$SENT_MSG_ID" "Start Pushing."
        push_github
        push_gitlab
        printf "<b>ʙʀᴀɴᴅ: %s</b>" "${brand}" >| "${OUTDIR}"/tg.html
        {
          printf "\n<b>ᴅᴇᴠɪᴄᴇ: %s</b>" "${codename}"
          printf "\n<b>ᴠᴇʀsɪᴏɴ:</b> %s" "${release}"
          printf "\n<b>ғɪɴɢᴇʀᴘʀɪɴᴛ:</b> %s" "${fingerprint}"
          printf "\n<a href=\"https://%s/%s/%s/-/tree/%s/\">ɢɪᴛʟᴀʙ ᴛʀᴇᴇ</a>" "${GITLAB_INSTANCE}" "${GIT_ORG}" "${repo}" "${branch}"
          printf "\n<b>ғᴏʟʟᴏᴡ @saurajdumps</b>"
        } >> "${OUTDIR}"/tg.html
        TEXT=$(cat "${OUTDIR}"/tg.html)
        tg --editmsghtml "$BOT_CHAT_ID" "$SENT_MSG_ID" "$TEXT"
  }

main $1 $2
### EOF
