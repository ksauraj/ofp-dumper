#1/usr/bin/env bash

push_gitlab() {
        # Gitlab Vars
        cd "${DUMPER_DIR}"
        if [ -z  "GITLAB_TOKEN" ]; then
            echo "Gitlab Token Not Found"
            echo "Dumping Locally"
            exit 1
        else
            echo "Gitlab token found, starting commit."
        fi
        if [ -z  "$GITLAB_INSTANCE" ]; then
            GITLAB_INSTANCE="gitlab.com"
        else
            echo "$GITLAB_INSTANCE"
        fi
        GITLAB_HOST="https://${GITLAB_INSTANCE}"

        # Check if already dumped or not
        [[ $(curl -sL "${GITLAB_HOST}/${GIT_ORG}/${repo}/-/raw/${branch}/all_files.txt" | grep "all_files.txt") ]] && { printf "Firmware already dumped!\nGo to https://"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}/-/tree/${branch}\n" && exit 1; }

        # Remove The Journal File Inside System/Vendor
        find . -mindepth 2 -type d -name "\[SYS\]" -exec rm -rf {} \; 2>/dev/null
        printf "\nFinal Repository Should Look Like...\n" && ls -lAog
        printf "\n\nStarting Git Init...\n"

        git init		# Insure Your GitLab Authorization Before Running This Script
        git config --global http.postBuffer 524288000		# A Simple Tuning to Get Rid of curl (18) error while `git push`
        git checkout -b "${branch}" || { git checkout -b "${incremental}" && export branch="${incremental}"; }
        find . \( -name "*sensetime*" -o -name "*.lic" \) | cut -d'/' -f'2-' >| .gitignore
        [[ ! -s .gitignore ]] && rm .gitignore
        [[ -z "$(git config --get user.email)" ]] && git config user.email "kumarsauraj24@gmail.com"
        [[ -z "$(git config --get user.name)" ]] && git config user.name "ksauraj"
        git add --all

        # Create Subgroup
        GRP_ID=$(curl -s --request GET --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" "${GITLAB_HOST}/api/v4/groups/${GIT_ORG}" | jq -r '.id')
        curl --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data '{"name": "'"${brand}"'", "path": "'"$(echo ${brand} | tr [:upper:] [:lower:])"'", "visibility": "public", "parent_id": "'"${GRP_ID}"'"}' \
        "${GITLAB_HOST}/api/v4/groups/"
        echo ""

        # Subgroup ID
        get_gitlab_subgrp_id(){
            local SUBGRP=$(echo "$1" | tr '[:upper:]' '[:lower:]')
            curl -s --request GET --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "${GITLAB_HOST}/api/v4/groups/${GIT_ORG}/subgroups" | jq -r .[] | jq -r .path,.id > /tmp/subgrp.txt
            local N_TMP=$(wc -l /tmp/subgrp.txt | cut -d\  -f1)
            local i
            for ((i=1; i<=$N_TMP; i++))
            do
                local TMP_I=$(cat /tmp/subgrp.txt | head -"$i" | tail -1)
                [[ "$TMP_I" == "$SUBGRP" ]] && cat /tmp/subgrp.txt | head -$(("$i"+1)) | tail -1 > "$2"
            done
            }

        get_gitlab_subgrp_id ${brand} /tmp/subgrp_id.txt
        SUBGRP_ID=$(< /tmp/subgrp_id.txt)

        # Create Repository
        curl -s \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -X POST \
        "${GITLAB_HOST}/api/v4/projects?name=${codename}&namespace_id=${SUBGRP_ID}&visibility=public"

        # Get Project/Repo ID
        get_gitlab_project_id(){
            local PROJ="$1"
            curl -s --request GET --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "${GITLAB_HOST}/api/v4/groups/$2/projects" | jq -r .[] | jq -r .path,.id > /tmp/proj.txt
            local N_TMP=$(wc -l /tmp/proj.txt | cut -d\  -f1)
            local i
            for ((i=1; i<=$N_TMP; i++))
            do
                local TMP_I=$(cat /tmp/proj.txt | head -"$i" | tail -1)
                [[ "$TMP_I" == "$PROJ" ]] && cat /tmp/proj.txt | head -$(("$i"+1)) | tail -1 > "$3"
            done
            }
        get_gitlab_project_id ${codename} ${SUBGRP_ID} /tmp/proj_id.txt
        PROJECT_ID=$(< /tmp/proj_id.txt)

        # Delete the Temporary Files
        rm -rf /tmp/{subgrp,subgrp_id,proj,proj_id}.txt

        # Commit and Push
        # Pushing via HTTPS doesn't work on GitLab for Large Repos (it's an issue with gitlab for large repos)
        # NOTE: Your SSH Keys Needs to be Added to your Gitlab Instance
        git remote add origin git@${GITLAB_INSTANCE}:${GIT_ORG}/${repo}.git
        git commit -asm "Add ${description}"

        # Ensure that the target repo is public
        curl --request PUT --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" --url ''"${GITLAB_HOST}"'/api/v4/projects/'"${PROJECT_ID}"'' --data "visibility=public"
        printf "\n"

        # Push the repo to GitLab
        while [[ ! $(curl -sL "${GITLAB_HOST}/${GIT_ORG}/${repo}/-/raw/${branch}/all_files.txt" | grep "all_files.txt") ]]
        do
            printf "\nPushing to %s via SSH...\nBranch:%s\n" "${GITLAB_HOST}/${GIT_ORG}/${repo}.git" "${branch}"
            sleep 1
            git push -u origin ${branch}
            sleep 1
        done

        # Update the Default Branch
        curl	--request PUT \
            --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
            --url ''"${GITLAB_HOST}"'/api/v4/projects/'"${PROJECT_ID}"'' \
            --data "default_branch=${branch}"
        printf "\n"
}
