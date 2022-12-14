#!/usr/bin/env bash

decrypt() {
        dtype=$DTYPE
        OFP_FILE=$(find -type f -iname '*.ofp')
        echo $OFP_FILE
        if [ $dtype == QC ]
        then
            printf "Trying to Decrypt QC OFP...\n"
            python3 ${ofp_qc_decrypt} "$OFP_FILE" out 2>/dev/null
        elif [ $dtype == MTK ]
        then
            printf "Trying to Decrypt MTK OFP...\n"
            python3 ${ofp_mtk_decrypt} "$OFP_FILE" out 2>/dev/null
        else
            printf "Specify your Device Type...\n"
            printf "Cancelling Build\n"
        fi
}
