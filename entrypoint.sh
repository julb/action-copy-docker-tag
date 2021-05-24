#!/bin/sh

set -e

DRY_RUN="${DRY_RUN:-false}"

main() {
    # Check commands
    check_cmd "docker"
    check_cmd "jq"

    # Check inputs
    check_input "${INPUT_USERNAME}" "username"
    check_input "${INPUT_PASSWORD}" "password"

    # File to process.
    DEST_FILE=/tmp/copy-docker-tag.txt

    # If no file provided, keep original method.
    if [ -z "${INPUT_FROM_FILE}" ]; then
        check_input "${INPUT_FROM}" "from"
        check_input "${INPUT_TAGS}" "tags"

        echo "${INPUT_FROM}=${INPUT_TAGS}" > "${DEST_FILE}"
    else
        # File provided - check existence
        check_file_exists "${INPUT_FROM_FILE}" "from_file"

        # If 
        case ${INPUT_FROM_FILE} in
        *.txt)
            # txt: copy as-is
            cp "${INPUT_FROM_FILE}" "${DEST_FILE}"
            ;;
        *.properties)
            # txt: copy as-is
            cp "${INPUT_FROM_FILE}" "${DEST_FILE}"
            ;;
        *.json)
            # json: get information from it using jq: key=src, value=tags[]
            jq -r 'to_entries[] | .key + "=" + (.value | join(","))' "${INPUT_FROM_FILE}" > "${DEST_FILE}"
            ;; 
        *)
            # ??: unsupported
            echo "File extension of ${INPUT_FROM_FILE} is not supported."
            exit 2
            ;;
        esac
    fi

    # Login to docker
    docker_login "${INPUT_USERNAME}" "${INPUT_PASSWORD}"

    # Proceed to copy.
    while read -r LINE; do
        # Skip if empty line
        if [ -z "${LINE}" ]; then
            continue
        fi

        # Skip if comment line
        case "${LINE}" in
            \#*)  continue ;;
            *) true ;;
        esac

        # Get from line - remove any escape character
        INPUT_FROM=$(echo "$LINE" | awk -F "=" '{print $1}' | sed 's/\\//g')
        INPUT_TAGS=$(echo "$LINE" | awk -F "=" '{print $2}' | sed 's/\\//g')

        # Force pull source
        docker_pull_tag "${INPUT_FROM}"

        # Copy tag
        INPUT_TAG_ARRAY=$(echo "$INPUT_TAGS" | sed 's/,/ /g')
        for INPUT_TAG in $INPUT_TAG_ARRAY; do
            docker_push_tag "${INPUT_FROM}" "${INPUT_TAG}"
        done
    done < "${DEST_FILE}"

    # Clean file
    rm "${DEST_FILE}"
    
    # Logout from docker
    docker_logout
}

check_cmd() {
    if ! command -v "${1}" > /dev/null 2>&1; then
        echo "'${1}' could not be found. Please install it."
        exit 1
    fi
}

check_input() {
    if [ -z "${1}" ]; then
        >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
        exit 2
    fi
}

check_file_exists() {
    if [ ! -f "${1}" ]; then
        >&2 echo "Unable to find the file ${2}. Did you put an existing file in with.${2}?"
        exit 2
    fi
}

docker_login() {
    # Get variable
    DOCKER_REGISTRY_USER=$1
    DOCKER_REGISTRY_PASSWORD=$2

    # Debug
    echo "::debug::login to dockerhub -> ${DOCKER_REGISTRY_USER}"

    # Trigger login
    if [ "$DRY_RUN" = false ]; then
        echo "${DOCKER_REGISTRY_PASSWORD}" | docker login -u "${DOCKER_REGISTRY_USER}" --password-stdin
    fi
}

docker_pull_tag() {
    # Get variable
    DOCKER_TAG=$1

    # Debug
    echo "::debug::pull tag ${DOCKER_TAG}"
    if [ "$DRY_RUN" = false ]; then
        docker pull "${DOCKER_TAG}"
    fi
}

docker_push_tag() {
    # Get variable
    DOCKER_TAG_SRC=$1
    DOCKER_TAG_DEST=$2

    # Copy tag
    echo "::debug::copy tag ${DOCKER_TAG_SRC} -> ${DOCKER_TAG_DEST}"
    if [ "$DRY_RUN" = false ]; then
        docker tag "${DOCKER_TAG_SRC}" "${DOCKER_TAG_DEST}"
    fi

    # Push tag
    echo "::debug::push tag ${DOCKER_TAG_DEST}"
    if [ "$DRY_RUN" = false ]; then
        docker push "${DOCKER_TAG_DEST}"
    fi
}

docker_logout() {
    echo "::debug::logout from docker"
    if [ "$DRY_RUN" = false ]; then
        docker logout
    fi
}

main