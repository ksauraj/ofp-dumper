#!/usr/bin/env bash

merge_super() {

        echo "Merging images"
        mkdir super
        cd out
        ln=$(grep -n super.img *scatter*.txt | cut -d : -f 1)
        echo $ln > number.txt
        sed -i "s/ /,\n/" number.txt
        gl=$(cat number.txt)
        if [[ "$gl" = *,* ]];
        then
            echo $ln > okay.sh && sed -i "s/ /\n/" okay.sh && sed  -i "1s/^/sln1=/" okay.sh && sed  -i "2s/^/sln2=/" okay.sh && echo '''sln3=$(($sln1+1))''' >> okay.sh && echo '''sln4=$(($sln2+1))''' >> okay.sh && echo '''sed -i "${sln3}s/false/true/" *scatter*.txt && sed -i "${sln4}s/false/true/" *scatter*.txt''' >> okay.sh && bash okay.sh
            rm okay.sh
        else
            sln=$(($ln+1)) && sed -i "${sln}s/false/true/" *scatter*.txt
        fi
        sed '2!d' super*.csv >> tmp.txt && sed -i "s/,/ /" tmp* && sed -i "s/,/ /" tmp* && sed -i "s/,/ /" tmp* && sed -i "s/,/ /" tmp* && egrep -o [a-zA-Z0-9.-]*super[a-zA-Z0-9.-]* tmp* >> supermap.sh && sed  -i "1s/^/first=/" supermap.sh && sed  -i "2s/^/second=/" supermap.sh && mkdir -p temp/retard && mkdir -p ../super && sed  -i "3s/^/third=/" supermap.sh && echo "cp \$first \$second \$third temp/retard/" >> supermap.sh && bash supermap.sh && cd temp/retard && sudo apt install simg2img && sudo apt-get install libz-dev
        simg2img *super*.img super.img
        mv ../../*super*.img ../../../super
        mv super.img ../..
        rm -rf temp/retard
        cd ..
        rm -rf retard
        cd ..
        rm -rf temp
}
