#!/usr/bin/env bash

unknown_decrypt() {
        pwd
        ls
        printf "Trying to Decrypt QC OFP...\n"
        python3 "${UTILSDIR}"/ofp_qc_decrypt.py "$OFP_FILE" out 2>/dev/null
        if [[ $? -ne 0 ]]; then
        printf "Trying to Decrypt MTK OFP...\n"
        python3 "${UTILSDIR}"/ofp_mtk_decrypt.py "$OFP_FILE" out 2>/dev/null
            if [[ $? -ne 0 ]]; then
                printf "OFP Decryption Error\n" && exit 1
            fi
        fi
        ls
        if [ -f ../*.csv ]; then cp *.csv out ; fi
}
