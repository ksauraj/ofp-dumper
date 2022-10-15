#!/usr/bin/env bash

extract_super(){
        cd "${PROJECT_DIR}"/dumper
        pwd
        mkdir -p tmp
        mv out/super.img tmp
        cd tmp
        if [[ ! -s super.img.raw ]] && [ -f super.img ]; then
            mv super.img super.img.raw
        fi
        local cur_path=$(pwd)
            ($LPUNPACK super.img.raw "$cur_path" || $LPUNPACK super.img.raw "$cur_path")
            if [ -f "$partition"_a.img ]; then
                mv "$partition"_a.img "$partition".img
            else
                foundpartitions=$(7z l -ba "${FILEPATH}" | rev | gawk '{ print $1 }' | rev | grep $partition.img)
                7z e -y "${FILEPATH}" $foundpartitions dummypartition 2>/dev/null >> $TMPDIR/zip.log
            fi
            rm *_b.img 2>/dev/null
        rm -rf super.img.raw
        cd ..
        mkdir -p work
        cp out/*.img work
        rm -rf out
        cp tmp/*.img work
        rm -rf tmp
}
