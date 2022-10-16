#!/usr/bin/env bash

push_github() {
        cd "${DUMPER_DIR}"
        rm ${OFP_FILE}
        if [[ -n $GIT_OAUTH_TOKEN ]]; then
            curl --silent --fail "https://raw.githubusercontent.com/$ORG/$repo/$branch/all_files.txt" 2> /dev/null && echo "Firmware already dumped!" && exit 1
            git init
            if [[ -z "$(git config --get user.email)" ]]; then
                git config user.email gitsauraj@gmail.com
            fi
            if [[ -z "$(git config --get user.name)" ]]; then
                git config user.name noobyysauraj
            fi
            git checkout -b "$branch"
            find . -size +97M -printf '%P\n' -o -name "*sensetime*" -printf '%P\n' -o -name "*.lic" -printf '%P\n' >| .gitignore
            git add --all

            curl -s -X POST -H "Authorization: token ${GIT_OAUTH_TOKEN}" -d '{ "name": "'"$repo"'" }' "https://api.github.com/orgs/${ORG}/repos" #create new repo
            curl -s -X PUT -H "Authorization: token ${GIT_OAUTH_TOKEN}" -H "Accept: application/vnd.github.mercy-preview+json" -d '{ "names": ["'"$manufacturer"'","'"$platform"'","'"$top_codename"'"]}' "https://api.github.com/repos/${ORG}/${repo}/topics"
            git remote add origin https://github.com/$ORG/"${repo,,}".git
            git update-ref -d HEAD
            git reset system/ vendor/
            git checkout -b "$branch"
            for d in */ ; do
                echo "Pushing $d"
                git add $d
                git commit -m "Add $d for ${description}"
                git push https://"$GIT_OAUTH_TOKEN"@github.com/$ORG/"${repo,,}".git "$branch"
                echo "Pushed $d"
            done
        else
            echo "Github token not found. Checking for Gitlab"
        fi
}
