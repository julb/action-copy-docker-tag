#!/bin/sh

set -e 

main() {
    # Check inputs
    check_input "${INPUT_USERNAME}" "username"
    check_input "${INPUT_PASSWORD}" "password"
    check_input "${INPUT_FROM}" "from"
    check_input "${INPUT_TAGS}" "tags"

    # Login to docker
    docker_login "${INPUT_USERNAME}" "${INPUT_PASSWORD}"

    # Force pull source
    docker_pull_tag "${INPUT_FROM}"

    # Copy tag
    for INPUT_TAG in ${INPUT_TAGS//,/ }; do
        docker_push_tag "${INPUT_FROM}" "${INPUT_TAG}"
    done
    
    # Logout from docker
    docker_logout
}

check_input() {
    if [ -z "${1}" ]; then
        >&2 echo "Unable to find the ${2}. Did you set with.${2}?"
        exit 1
    fi
}

docker_login() {
    # Get variable
    DOCKER_REGISTRY_USER=$1
    DOCKER_REGISTRY_PASSWORD=$2

    # Debug
    echo "::debug::login to dockerhub -> ${DOCKER_REGISTRY_USER}"

    # Trigger login
    echo "${DOCKER_REGISTRY_PASSWORD}" | docker login -u ${DOCKER_REGISTRY_USER} --password-stdin
}

docker_pull_tag() {
    # Get variable
    DOCKER_TAG=$1

    # Debug
    echo "::debug::pull tag ${DOCKER_TAG}"
    docker pull ${DOCKER_TAG}
}

docker_push_tag() {
    # Get variable
    DOCKER_TAG_SRC=$1
    DOCKER_TAG_DEST=$2

    # Copy tag
    echo "::debug::copy tag ${DOCKER_TAG_SRC} -> ${DOCKER_TAG_DEST}"
    docker tag ${DOCKER_TAG_SRC} ${DOCKER_TAG_DEST}

    # Push tag
    echo "::debug::push tag ${DOCKER_TAG_DEST}"
    docker push ${DOCKER_TAG_DEST}
}

docker_logout() {
    echo "::debug::logout from docker"
    docker logout
}

main