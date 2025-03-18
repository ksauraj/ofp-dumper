#!/usr/bin/env bash

board_info() {
            # board-info.txt
          OUTDIR="${DUMPER_DIR}"
          mkdir -p "${OUTDIR}"/temp 
          TMPDIR="${OUTDIR}"/temp 
          find "${OUTDIR}"/modem -type f -exec strings {} \; 2>/dev/null | grep "QC_IMAGE_VERSION_STRING=MPSS." | sed "s|QC_IMAGE_VERSION_STRING=MPSS.||g" | cut -c 4- | sed -e 's/^/require version-baseband=/' >> "${TMPDIR}"/board-info.txt
          find "${OUTDIR}"/tz* -type f -exec strings {} \; 2>/dev/null | grep "QC_IMAGE_VERSION_STRING" | sed "s|QC_IMAGE_VERSION_STRING|require version-trustzone|g" >> "${TMPDIR}"/board-info.txt
          if [ -e "${OUTDIR}"/vendor/build.prop ]; then
            strings "${OUTDIR}"/vendor/build.prop | grep "ro.vendor.build.date.utc" | sed "s|ro.vendor.build.date.utc|require version-vendor|g" >> "${TMPDIR}"/board-info.txt
          fi
          sort -u < "${TMPDIR}"/board-info.txt > "${OUTDIR}"/board-info.txt
          cd "${OUTDIR}"
          # set variables
          [[ $(find "$(pwd)"/system "$(pwd)"/system/system "$(pwd)"/vendor "$(pwd)"/*product -maxdepth 1 -type f -name "build*.prop" 2>/dev/null | sort -u | gawk '{print $NF}') ]] || { msg_dump "No system/vendor/product build*.prop found, pushing cancelled.\n" && exit 1; }

          flavor=$(grep -m1 -oP "(?<=^ro.build.flavor=).*" -hs {system,system/system,vendor}/build*.prop)
          [[ -z "${flavor}" ]] && flavor=$(grep -m1 -oP "(?<=^ro.vendor.build.flavor=).*" -hs vendor/build*.prop)
          [[ -z "${flavor}" ]] && flavor=$(grep -m1 -oP "(?<=^ro.system.build.flavor=).*" -hs {system,system/system}/build*.prop)
          [[ -z "${flavor}" ]] && flavor=$(grep -m1 -oP "(?<=^ro.build.type=).*" -hs {system,system/system}/build*.prop)
          release=$(grep -m1 -oP "(?<=^ro.build.version.release=).*" -hs {system,system/system,vendor}/build*.prop)
          [[ -z "${release}" ]] && release=$(grep -m1 -oP "(?<=^ro.vendor.build.version.release=).*" -hs vendor/build*.prop)
          [[ -z "${release}" ]] && release=$(grep -m1 -oP "(?<=^ro.system.build.version.release=).*" -hs {system,system/system}/build*.prop)
          id=$(grep -m1 -oP "(?<=^ro.build.id=).*" -hs {system,system/system,vendor}/build*.prop)
          [[ -z "${id}" ]] && id=$(grep -m1 -oP "(?<=^ro.vendor.build.id=).*" -hs vendor/build*.prop)
          [[ -z "${id}" ]] && id=$(grep -m1 -oP "(?<=^ro.system.build.id=).*" -hs {system,system/system}/build*.prop)
          tags=$(grep -m1 -oP "(?<=^ro.build.tags=).*" -hs {system,system/system,vendor}/build*.prop)
          [[ -z "${tags}" ]] && tags=$(grep -m1 -oP "(?<=^ro.vendor.build.tags=).*" -hs vendor/build*.prop)
          [[ -z "${tags}" ]] && tags=$(grep -m1 -oP "(?<=^ro.system.build.tags=).*" -hs {system,system/system}/build*.prop)
          platform=$(grep -m1 -oP "(?<=^ro.board.platform=).*" -hs {system,system/system,vendor}/build*.prop | head -1)
          [[ -z "${platform}" ]] && platform=$(grep -m1 -oP "(?<=^ro.vendor.board.platform=).*" -hs vendor/build*.prop)
          [[ -z "${platform}" ]] && platform=$(grep -m1 -oP "(?<=^ro.system.board.platform=).*" -hs {system,system/system}/build*.prop)
          manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {my_product}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {odm}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs {my_product}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs {odm}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {system,system/system,vendor}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {my_product,system,system/system,vendor}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.brand.sub=).*" -hs system/system/euclid/my_product/build*.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.vendor.product.manufacturer=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.vendor.manufacturer=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.system.product.manufacturer=).*" -hs {system,system/system}/build*.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.system.manufacturer=).*" -hs {odm,system,system/system}/build*.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.odm.manufacturer=).*" -hs vendor/odm/etc/build*.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs {oppo_product,my_product,product}/build*.prop | head -1)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.manufacturer=).*" -hs vendor/euclid/*/build.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.system.product.manufacturer=).*" -hs vendor/euclid/*/build.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.product.manufacturer=).*" -hs vendor/euclid/product/build*.prop)
          [[ -z "${manufacturer}" ]] && manufacturer=$(grep -m1 -oP "(?<=^ro.product.product.manufacturer=).*" -hs product/etc/build*.prop)
          fingerprint=$(grep -m1 -oP "(?<=^ro.build.fingerprint=).*" -hs {system,system/system}/build*.prop)
          [[ -z "${fingerprint}" ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.vendor.build.fingerprint=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${fingerprint}" ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.system.build.fingerprint=).*" -hs {system,system/system}/build*.prop)
          [[ -z "${fingerprint}" ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.product.build.fingerprint=).*" -hs product/build*.prop)
          [[ -z "${fingerprint}" ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.build.fingerprint=).*" -hs {oppo_product,my_product}/build*.prop)
          [[ -z "${fingerprint}" ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.system.build.fingerprint=).*" -hs my_product/build.prop)
          [[ -z "${fingerprint}" ]] && fingerprint=$(grep -m1 -oP "(?<=^ro.vendor.build.fingerprint=).*" -hs my_product/build.prop)
          brand=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs {my_product,odm,system,system/system,vendor}/build*.prop | head -1)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.brand.sub=).*" -hs odm/build*.prop)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.brand.sub=).*" -hs system/system/euclid/my_product/build*.prop)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.vendor.brand=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.vendor.product.brand=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.system.brand=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${brand}" || ${brand} == "OPPO" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.system.brand=).*" -hs vendor/euclid/*/build.prop | head -1)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.product.brand=).*" -hs vendor/euclid/product/build*.prop)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.odm.brand=).*" -hs vendor/odm/etc/build*.prop)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs {oppo_product,my_product}/build*.prop | head -1)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.brand=).*" -hs vendor/euclid/*/build.prop | head -1)
          [[ -z "${brand}" ]] && brand=$(echo "$fingerprint" | cut -d'/' -f1)
          [[ -z "${brand}" ]] && brand=$(grep -m1 -oP "(?<=^ro.product.product.brand=).*" -hs product/etc/build*.prop)
          codename=$(grep -m1 -oP "(?<=^ro.build.product=).*" -hs {odm,vendor,system,system/system}/build*.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.device=).*" -hs {vendor,system,system/system}/build*.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.vendor.product.device.oem=).*" -hs vendor/euclid/odm/build.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.vendor.device=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.vendor.product.device=).*" -hs vendor/build*.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.system.device=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.system.device=).*" -hs vendor/euclid/*/build.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.device=).*" -hs vendor/euclid/*/build.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.model=).*" -hs vendor/euclid/*/build.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.device=).*" -hs {oppo_product,my_product}/build*.prop | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.device=).*" -hs oppo_product/build*.prop)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.system.device=).*" -hs my_product/build*.prop)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.vendor.device=).*" -hs my_product/build*.prop)
          [[ -z "${codename}" ]] && codename=$(echo "$fingerprint" | cut -d'/' -f3 | cut -d':' -f1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.build.fota.version=).*" -hs {system,system/system}/build*.prop | cut -d'-' -f1 | head -1)
          [[ -z "${codename}" ]] && codename=$(grep -m1 -oP "(?<=^ro.product.product.device=).*" -hs product/etc/build*.prop)
          description=$(grep -m1 -oP "(?<=^ro.build.description=).*" -hs {system,system/system,vendor}/build*.prop | head -1)
          [[ -z "${description}" ]] && description=$(grep -m1 -oP "(?<=^ro.vendor.build.description=).*" -hs vendor/build*.prop)
          [[ -z "${description}" ]] && description=$(grep -m1 -oP "(?<=^ro.system.build.description=).*" -hs {system,system/system}/build*.prop)
          [[ -z "${description}" ]] && description=$(grep -m1 -oP "(?<=^ro.product.build.description=).*" -hs product/build.prop)
          [[ -z "${description}" ]] && description=$(grep -m1 -oP "(?<=^ro.product.build.description=).*" -hs product/build*.prop)
          incremental=$(grep -m1 -oP "(?<=^ro.build.version.incremental=).*" -hs {system,system/system,vendor}/build*.prop | head -1)
          [[ -z "${incremental}" ]] && incremental=$(grep -m1 -oP "(?<=^ro.vendor.build.version.incremental=).*" -hs vendor/build*.prop)
          [[ -z "${incremental}" ]] && incremental=$(grep -m1 -oP "(?<=^ro.system.build.version.incremental=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${incremental}" ]] && incremental=$(grep -m1 -oP "(?<=^ro.build.version.incremental=).*" -hs my_product/build*.prop)
          [[ -z "${incremental}" ]] && incremental=$(grep -m1 -oP "(?<=^ro.system.build.version.incremental=).*" -hs my_product/build*.prop)
          [[ -z "${incremental}" ]] && incremental=$(grep -m1 -oP "(?<=^ro.vendor.build.version.incremental=).*" -hs my_product/build*.prop)
          # For Realme devices with empty incremental & fingerprint,
          [[ -z "${incremental}" && "${brand}" =~ "realme" ]] && incremental=$(grep -m1 -oP "(?<=^ro.build.version.ota=).*" -hs {vendor/euclid/product,oppo_product}/build.prop | rev | cut -d'_' -f'1-2' | rev)
          [[ -z "${incremental}" && ! -z "${description}" ]] && incremental=$(echo "${description}" | cut -d' ' -f4)
          [[ -z "${description}" && ! -z "${incremental}" ]] && description="${flavor} ${release} ${id} ${incremental} ${tags}"
          [[ -z "${description}" && -z "${incremental}" ]] && description="${codename}"
          
          # Additional build.prop information from product and boot
          [[ -z "${description}" ]] && description=$(grep -m1 -oP "(?<=^ro.product.build.description=).*" -hs boot/ramdisk/system/etc/ramdisk/build.prop)
          build_date=$(grep -m1 -oP "(?<=^ro.product.build.date=).*" -hs boot/ramdisk/system/etc/ramdisk/build.prop)
          build_date_utc=$(grep -m1 -oP "(?<=^ro.product.build.date.utc=).*" -hs boot/ramdisk/system/etc/ramdisk/build.prop)
          [[ -z "${incremental}" ]] && incremental=$(grep -m1 -oP "(?<=^ro.product.build.version.incremental=).*" -hs boot/ramdisk/system/etc/ramdisk/build.prop)
          model=$(grep -m1 -oP "(?<=^ro.product.product.model=).*" -hs product/etc/build*.prop)
          
          abilist=$(grep -m1 -oP "(?<=^ro.product.cpu.abilist=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${abilist}" ]] && abilist=$(grep -m1 -oP "(?<=^ro.vendor.product.cpu.abilist=).*" -hs vendor/build*.prop)
          locale=$(grep -m1 -oP "(?<=^ro.product.locale=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${locale}" ]] && locale=undefined
          density=$(grep -m1 -oP "(?<=^ro.sf.lcd_density=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${density}" ]] && density=undefined
          is_ab=$(grep -m1 -oP "(?<=^ro.build.ab_update=).*" -hs {system,system/system,vendor}/build*.prop)
          [[ -z "${is_ab}" ]] && is_ab="false"
          otaver=$(grep -m1 -oP "(?<=^ro.build.version.ota=).*" -hs {vendor/euclid/product,oppo_product}/build.prop | head -1)
          [[ ! -z "${otaver}" && -z "${fingerprint}" ]] && branch=$(echo "${otaver}" | tr ' ' '-')
          [[ -z "${otaver}" ]] && otaver=$(grep -m1 -oP "(?<=^ro.build.fota.version=).*" -hs {system,system/system}/build*.prop | head -1)
          [[ -z "${branch}" ]] && branch=$(echo "${description}" | tr ' ' '-')
          RANDOM=$(date +%s%N | cut -b10-19)
          repo=$(echo "${brand}"_"${codename}"_dump_"${RANDOM}" | tr '[:upper:]' '[:lower:]')
          platform=$(echo "${platform}" | tr '[:upper:]' '[:lower:]' | tr -dc '[:print:]' | tr '_' '-' | cut -c 1-35)
          top_codename=$(echo "${codename}" | tr '[:upper:]' '[:lower:]' | tr -dc '[:print:]' | tr '_' '-' | cut -c 1-35)
          manufacturer=$(echo "${manufacturer}" | tr '[:upper:]' '[:lower:]' | tr -dc '[:print:]' | tr '_' '-' | cut -c 1-35)
          # Repo README File
          printf "## %s\n- Manufacturer: %s\n- Platform: %s\n- Codename: %s\n- Brand: %s\n- Flavor: %s\n- Release Version: %s\n- Id: %s\n- Incremental: %s\n- Tags: %s\n- CPU Abilist: %s\n- A/B Device: %s\n- Locale: %s\n- Screen Density: %s\n- Fingerprint: %s\n- OTA version: %s\n- Branch: %s\n- Repo: %s\n" "${description}" "${manufacturer}" "${platform}" "${codename}" "${brand}" "${flavor}" "${release}" "${id}" "${incremental}" "${tags}" "${abilist}" "${is_ab}" "${locale}" "${density}" "${fingerprint}" "${otaver}" "${branch}" "${repo}" > "${OUTDIR}"/README.md
          printf "\n\n>Follow Sauraj-Dumps\n" >> "${OUTDIR}"/README.md
          rm -rf "${OUTDIR}"/temp 
}
