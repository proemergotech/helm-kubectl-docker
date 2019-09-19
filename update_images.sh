#!/usr/bin/env bash

set -euo pipefail

# stop script not just the current command
trap "exit" SIGINT SIGTERM

resources=$(kubectl -n ${CI_ENVIRONMENT_NAME} get deployment,daemonset,statefulset -l dliver.com/project=${CI_PROJECT_NAME} -o json)
item_count=$(jq -r '.items | length' <<< ${resources}) 

if [[ ${item_count} == 0 ]]; then
    echo "Resource for project '${CI_PROJECT_NAME}' not found"
    exit 1
fi

for (( i = 0; i < ${item_count}; i++ )); do
    resource=$(jq -r ".items[$i]" <<< ${resources})
    resource_identifier=$(jq -r '.kind + "/" + .metadata.name' <<< ${resource})
    container_names=($(jq -r '.spec.template.spec | .containers[],.initContainers[]? | select(.image | contains($ENV.CI_PROJECT_NAME)) | .name' <<< ${resource}))
    
    image_updates=()
    for container in ${container_names[@]} 
    do
        image_updates+=("${container}=${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}:${CI_COMMIT_SHA}")
    done

    kubectl -n ${CI_ENVIRONMENT_NAME} set image ${resource_identifier} ${image_updates[@]} 
done