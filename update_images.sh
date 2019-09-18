#!/usr/bin/env bash

set -euo pipefail

# stop script not just the current command
trap "exit" SIGINT SIGTERM

resource=$(kubectl -n ${CI_ENVIRONMENT_NAME} get deployment,daemonset,statefulset -l app=${CI_PROJECT_NAME} -o json)
item_count=$(echo ${resource} | jq -r '.items | length') 

if [[ ${item_count} > 1 ]]; then
    echo "Found more than 1 resource: "
    echo "$(echo ${resource} | jq -r '.items[] | .kind + "/" + .metadata.name')"
    exit 1
elif [[ ${item_count} == 0 ]]; then
    echo "Resource '${CI_PROJECT_NAME}' not found"
    exit 1
fi

resource_kind=$(echo ${resource} | jq -r '.items[].kind')
container_names=($(echo ${resource} | jq -r '.items[].spec.template.spec | .containers[],.initContainers[] | select(.image | contains($ENV.CI_PROJECT_NAME)) | .name' ))

image_updates=()
for container in ${container_names[@]} 
do
    image_updates+=("${container}=${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}:${CI_COMMIT_SHA}")
done

kubectl -n ${CI_ENVIRONMENT_NAME} set image ${resource_kind}/${CI_PROJECT_NAME} ${image_updates[@]} 