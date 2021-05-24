#!/bin/sh

set -e 

main() {
    # Check commands
    check_cmd "docker"
    check_cmd "jq"

    # Check inputs
    check_input "${INPUT_USERNAME}" "username"
    check_input "${INPUT_PASSWORD}" "password"

    # If no file provided, keep original method.
    if [ -z "${INPUT_FROM_FILE}" ]; then
        check_input "${INPUT_FROM}" "from"
        check_input "${INPUT_TAGS}" "tags"

        # Login to docker
        docker_login "${INPUT_USERNAME}" "${INPUT_PASSWORD}"

        # Force pull source
        docker_pull_tag "${INPUT_FROM}"

        # Copy tag
        INPUT_TAG_ARRAY=$(echo "$INPUT_TAGS" | sed 's/,/ /g')
        for INPUT_TAG in $INPUT_TAG_ARRAY; do
            docker_push_tag "${INPUT_FROM}" "${INPUT_TAG}"
        done
        
        # Logout from docker
        docker_logout
    else
        # File provided - check existence
        check_file_exists "${INPUT_FROM_FILE}" "from_file"

        # Extract information from it: key=src, value=tags[]
        jq -r 'to_entries[] | .key + "|" + (.value | join(","))' "${INPUT_FROM_FILE}" > /tmp/jq.copy-docker-tag.txt

        # Login to docker
        docker_login "${INPUT_USERNAME}" "${INPUT_PASSWORD}"

        # Proceed to copy.
        while read -r LINE; do
            # Get from
            INPUT_FROM=$(echo "$LINE" | awk -F "|" '{print $1}')
            INPUT_TAGS=$(echo "$LINE" | awk -F "|" '{print $2}')

            # Force pull source
            docker_pull_tag "${INPUT_FROM}"

            # Copy tag
            INPUT_TAG_ARRAY=$(echo "$INPUT_TAGS" | sed 's/,/ /g')
            for INPUT_TAG in $INPUT_TAG_ARRAY; do
                docker_push_tag "${INPUT_FROM}" "${INPUT_TAG}"
            done
        done < /tmp/jq.copy-docker-tag.txt

        # Clean file
        rm /tmp/jq.copy-docker-tag.txt
        
        # Logout from docker
        docker_logout
    fi
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
    echo "${DOCKER_REGISTRY_PASSWORD}" | docker login -u "${DOCKER_REGISTRY_USER}" --password-stdin
}

docker_pull_tag() {
    # Get variable
    DOCKER_TAG=$1

    # Debug
    echo "::debug::pull tag ${DOCKER_TAG}"
    docker pull "${DOCKER_TAG}"
}

docker_push_tag() {
    # Get variable
    DOCKER_TAG_SRC=$1
    DOCKER_TAG_DEST=$2

    # Copy tag
    echo "::debug::copy tag ${DOCKER_TAG_SRC} -> ${DOCKER_TAG_DEST}"
    docker tag "${DOCKER_TAG_SRC}" "${DOCKER_TAG_DEST}"

    # Push tag
    echo "::debug::push tag ${DOCKER_TAG_DEST}"
    docker push "${DOCKER_TAG_DEST}"
}

docker_logout() {
    echo "::debug::logout from docker"
    docker logout
}

main