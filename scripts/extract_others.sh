#!/usr/bin/env bash

install_external_tools(){
    EXTERNAL_TOOLS=(
        bkerler/oppo_ozip_decrypt
        bkerler/oppo_decrypt
        marin-m/vmlinux-to-elf
        ShivamKumarJha/android_tools
        HemanthJabalpuri/pacextractor
    )

    for tool_slug in "${EXTERNAL_TOOLS[@]}"; do
        if ! [[ -d "${UTILSDIR}"/"${tool_slug#*/}" ]]; then
            git clone -q https://github.com/"${tool_slug}".git "${UTILSDIR}"/"${tool_slug#*/}"
        else
            git -C "${UTILSDIR}"/"${tool_slug#*/}" pull
        fi
    done
}

extract_others() {
    # Extract boot.img
    if [[ -f "${OUTDIR}"/boot.img ]]; then
        # Extract dts
        mkdir -p "${OUTDIR}"/bootimg "${OUTDIR}"/bootdts 2>/dev/null
        python3 "${DTB_EXTRACTOR}" "${OUTDIR}"/boot.img -o "${OUTDIR}"/bootimg >/dev/null
        find "${OUTDIR}"/bootimg -name '*.dtb' -type f | gawk -F'/' '{print $NF}' | while read -r i; do "${DTC}" -q -s -f -I dtb -O dts -o bootdts/"${i/\.dtb/.dts}" bootimg/"${i}"; done 2>/dev/null
        bash "${UNPACKBOOT}" "${OUTDIR}"/boot.img "${OUTDIR}"/boot 2>/dev/null
        echo "Boot extracted\n"
        # extract-ikconfig
        mkdir -p "${OUTDIR}"/bootRE
        bash "${EXTRACT_IKCONFIG}" "${OUTDIR}"/boot.img > "${OUTDIR}"/bootRE/ikconfig 2> /dev/null
        [[ ! -s "${OUTDIR}"/bootRE/ikconfig ]] && rm -f "${OUTDIR}"/bootRE/ikconfig 2>/dev/null
        # vmlinux-to-elf
        if [[ ! -f "${OUTDIR}"/vendor_boot.img ]]; then
            python3 "${KALLSYMS_FINDER}" "${OUTDIR}"/boot.img > "${OUTDIR}"/bootRE/boot_kallsyms.txt >/dev/null 2>&1
            echo "boot_kallsyms.txt generated\n"
        else
            python3 "${KALLSYMS_FINDER}" "${OUTDIR}"/boot/kernel > "${OUTDIR}"/bootRE/kernel_kallsyms.txt >/dev/null 2>&1
            echo "kernel_kallsyms.txt generated\n"
        fi
        python3 "${VMLINUX2ELF}" "${OUTDIR}"/boot.img "${OUTDIR}"/bootRE/boot.elf >/dev/null 2>&1
        echo "boot.elf generated\n"
    fi

    # Extract vendor_boot.img
    if [[ -f "${OUTDIR}"/vendor_boot.img ]]; then
        # Extract dts
        mkdir -p "${OUTDIR}"/vendor_bootimg "${OUTDIR}"/vendor_bootdts 2>/dev/null
        python3 "${DTB_EXTRACTOR}" "${OUTDIR}"/vendor_boot.img -o "${OUTDIR}"/vendor_bootimg >/dev/null
        find "${OUTDIR}"/vendor_bootimg -name '*.dtb' -type f | gawk -F'/' '{print $NF}' | while read -r i; do "${DTC}" -q -s -f -I dtb -O dts -o vendor_bootdts/"${i/\.dtb/.dts}" vendor_bootimg/"${i}"; done 2>/dev/null
        bash "${UNPACKBOOT}" "${OUTDIR}"/vendor_boot.img "${OUTDIR}"/vendor_boot 2>/dev/null
        echo "Vendor Boot extracted\n"
        # extract-ikconfig
        mkdir -p "${OUTDIR}"/vendor_bootRE
        # vmlinux-to-elf
        python3 "${VMLINUX2ELF}" "${OUTDIR}"/vendor_boot.img "${OUTDIR}"/vendor_bootRE/vendor_boot.elf >/dev/null 2>&1
        echo "vendor_boot.elf generated\n"
    fi

    # Extract recovery.img
    if [[ -f "${OUTDIR}"/recovery.img ]]; then
        bash "${UNPACKBOOT}" "${OUTDIR}"/recovery.img "${OUTDIR}"/recovery 2>/dev/null
        echo "Recovery extracted\n"
    fi

    # Extract dtbo
    if [[ -f "${OUTDIR}"/dtbo.img ]]; then
        mkdir -p "${OUTDIR}"/dtbo "${OUTDIR}"/dtbodts 2>/dev/null
        python3 "${DTB_EXTRACTOR}" "${OUTDIR}"/dtbo.img -o "${OUTDIR}"/dtbo >/dev/null
        find "${OUTDIR}"/dtbo -name '*.dtb' -type f | gawk -F'/' '{print $NF}' | while read -r i; do "${DTC}" -q -s -f -I dtb -O dts -o dtbodts/"${i/\.dtb/.dts}" dtbo/"${i}"; done 2>/dev/null
        echo "dtbo extracted\n"
    fi
    ## Move files to DUMPER_DIR.
    mv "${OUTDIR}"/boot.img "${DUMPER_DIR}"
    mv "${OUTDIR}"/vendor_boot.img "${DUMPER_DIR}"
    mv "${OUTDIR}"/recovery.img "${DUMPER_DIR}"
    mv "${OUTDIR}"/dtbo.img "${DUMPER_DIR}"
    mv "${OUTDIR}"/boot "${DUMPER_DIR}"
    mv "${OUTDIR}"/bootRE "${DUMPER_DIR}"
    mv "${OUTDIR}"/dtb "${DUMPER_DIR}"
    mv "${OUTDIR}"/dtbo "${DUMPER_DIR}"
    mv "${OUTDIR}"/modem "${DUMPER_DIR}"
    sudo rm -rf "${OUTDIR}"
    cd "${DUMPER_DIR}"
    sudo chown "$(whoami)" ./* -R
    sudo chmod -R u+rwX ./* #ensure final permissions
    find "${DUMPER_DIR}" -type f -printf '%P\n' | sort | grep -v ".git/" > "${DUMPER_DIR}"/all_files.txt
    for d in $(find ./ -maxdepth 1 -type d  -empty); do sudo rm -rf $d; done
}
