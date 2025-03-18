#!/usr/bin/env bash

push_gitlab() {
    # Gitlab Vars
    cd "${DUMPER_DIR}"
    if [ -z  "$GITLAB_TOKEN" ]; then
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
    
    # Set default values for required variables
    branch="${branch:-master}"
    repo="${repo:-firmware_dump}"
    description="${description:-Firmware dump}"
    GIT_ORG="${GIT_ORG:-$GIT_USER}"
    GITLAB_VISIBILITY="${GITLAB_VISIBILITY:-public}"
    
    # Validate visibility
    if [ "$GITLAB_VISIBILITY" != "public" ] && [ "$GITLAB_VISIBILITY" != "private" ]; then
        echo "Invalid visibility value. Using default: public"
        GITLAB_VISIBILITY="public"
    fi
    
    export GIT_USER="ksauraj"
    export LAB_CORE_TOKEN="$GITLAB_TOKEN"
    GITLAB_HOST="https://${GITLAB_INSTANCE}"
    
    curl -sf "https://"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}/-/raw/${branch}/all_files.txt" | grep "all_files.txt" && { 
        msg_dump "Firmware already dumped!\nGo to https://"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}/-/tree/${branch}\n" && exit 1; 
    }  # Add grep to fix gitlab login error
    
    # Remove The Journal File Inside System/Vendor
    find . -mindepth 2 -type d -name "\[SYS\]" -exec rm -rf {} \; 2>/dev/null
    
    # Files larger than 62MB will be split into 47MB parts as *.aa, *.ab, etc.
    mkdir -p "${TMPDIR}" 2>/dev/null
    find . -size +62M | cut -d'/' -f'2-' >| "${TMPDIR}"/.largefiles
    if [[ -s "${TMPDIR}"/.largefiles ]]; then
        printf '#!/bin/bash\n\n' > join_split_files.sh
        while read -r l; do
            split -b 47M "${l}" "${l}".
            rm -f "${l}" 2>/dev/null
            printf "cat %s.* 2>/dev/null >> %s\n" "${l}" "${l}" >> join_split_files.sh
            printf "rm -f %s.* 2>/dev/null\n" "${l}" >> join_split_files.sh
        done < "${TMPDIR}"/.largefiles
        chmod a+x join_split_files.sh 2>/dev/null
    fi
    rm -rf "${TMPDIR}" 2>/dev/null
    
    printf "\nFinal Repository Should Look Like...\n" && ls -lAog
    printf "\n\nStarting Git Init...\n"
    MESSAGE="Firmware Dumped Successfully, Pushing To ${GITLAB_INSTANCE}"
    
    git init # Insure Your GitLab Authorization Before Running This Script
    git config --global http.postBuffer 524288000 # A Simple Tuning to Get Rid of curl (18) error while git push
    git config --global user.name "Sauraj Kumar"
    git config --global user.email "rommirrorer@gmail.com"
    git checkout -b "${branch}"
    
    find . \( -name "*sensetime*" -o -name "*.lic" \) | cut -d'/' -f'2-' >| .gitignore
    [[ ! -s .gitignore ]] && rm .gitignore
    git add --all
    
    if [[ "${GIT_ORG}" == "${GIT_USER}" ]]; then
        lab project create ${repo} -d "${description}" --http --visibility="${GITLAB_VISIBILITY}"
    else
        lab project create -g "${GIT_ORG}" "${repo}" -d "${description}" --http --visibility="${GITLAB_VISIBILITY}"
    fi
    
    git remote add origin https://"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}.git
    git commit -asm "Add ${description}"
    
    { [[ $(du -bs . | cut -f1) -lt 1288490188 ]] && git push https://${GIT_USER}:${GITLAB_TOKEN}@"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}.git "${branch}"; } || (
        git update-ref -d HEAD
        git reset system/ vendor/
        git checkout -b "${branch}"
        git commit -asm "Add extras for ${description}"
        git push https://${GIT_USER}:${GITLAB_TOKEN}@"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}.git "${branch}"
        git add vendor/
        git commit -asm "Add vendor for ${description}"
        git push https://${GIT_USER}:${GITLAB_TOKEN}@"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}.git "${branch}"
        git add system/system/app/ system/system/priv-app/ || git add system/app/ system/priv-app/
        git commit -asm "Add apps for ${description}"
        git push https://${GIT_USER}:${GITLAB_TOKEN}@"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}.git "${branch}"
        git add system/
        git commit -asm "Add system for ${description}"
        git push https://${GIT_USER}:${GITLAB_TOKEN}@"$GITLAB_INSTANCE"/${GIT_ORG}/${repo}.git "${branch}"
    )
    
    # Ensure repository visibility is set correctly using GitLab API
    echo "Verifying repository visibility..."
    PROJECT_ID=$(echo "${GIT_ORG}/${repo}" | sed 's/\//%2F/g')
    curl -s -X PUT \
        -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"visibility\":\"${GITLAB_VISIBILITY}\"}" \
        "https://${GITLAB_INSTANCE}/api/v4/projects/${PROJECT_ID}" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo "Repository visibility set to ${GITLAB_VISIBILITY}"
    else
        echo "Warning: Failed to verify repository visibility. Please check manually."
    fi
}
