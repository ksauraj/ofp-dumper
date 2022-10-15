#!/usr/bin/env bash

unknown_decrypt() {
        printf "Trying to Decrypt QC OFP...\n"
        python3 ./oppo_decrypt/ofp_qc_extract.py "$OFP_FILE" out 2>/dev/null
        if [[ ! -f out/super.img || ! -f out/system.img ]]; then
        printf "Trying to Decrypt MTK OFP...\n"
        python3 ./oppo_decrypt/ofp_mtk_decrypt.py "$OFP_FILE" out 2>/dev/null
            if [[ ! -f out/super.img || ! -f out/system.img ]]; then
                printf "OFP Decryption Error\n" && exit 1
            fi
        fi
}
