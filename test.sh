#!/usr/bin/env bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
if echo "${PROJECT_DIR}" | grep " "; then
	printf "\nProject Directory Path Contains Empty Space,\nPlace The Script In A Proper UNIX-Formatted Folder\n\n"
	sleep 1s && exit 1
fi
EROFSFUSE=${PROJECT_DIR}/utils/erofsfuse

extract_partitions() {
        cd "${PROJECT_DIR}"/dumper/work
        PARTITIONS="system system_ext system_other systemex vendor cust odm oem factory product xrom modem dtbo dtb boot vendor_boot recovery tz oppo_product preload_common opproduct reserve india my_preload my_odm my_stock my_operator my_country my_product my_company my_engineering my_heytap my_custom my_manifest my_carrier my_region my_bigball my_version special_preload system_dlkm vendor_dlkm odm_dlkm init_boot vendor_kernel_boot"
        echo "$PARTITIONS"
        for p in $PARTITIONS; do
            if ! echo "${p}" | grep -q "boot\|recovery\|dtbo\|vendor_boot\|tz"; then
                            mkdir -p "$p" 
                            if [ -f "$p"_a.img ]; then
                            ${EROFSFUSE} "$p"_a.img "$p"
                            else
                            ${EROFSFUSE} "$p".img "$p"
                            fi
                            mkdir -p ../"${p}_"
                            cp -rf "${p}/"* ../"${p}_"
                            umount "${p}"
                            mv ../"${p}_/" ../"${p}"
                            if [ $? -eq 0 ]; then
                                rm -fv "$p".img > /dev/null 2>&1
                            else

                                                               echo "For EROFS: make sure you're using Linux 5.4+ kernel."
                                    echo "For F2FS: make sure you're using Linux 5.15+ kernel."
                                fi
                            fi
        done
}

extract_partitions
