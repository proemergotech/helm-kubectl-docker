#!/usr/bin/env bash

set -euo pipefail

# stop script not just the current command
trap "exit" SIGINT SIGTERM

resource_kind=$(kubectl -n ${CI_ENVIRONMENT_NAME} get deployment,daemonset,statefulset -l app=${CI_PROJECT_NAME} -o json | jq -r '.items[].kind')
container_names=($(kubectl -n ${CI_ENVIRONMENT_NAME} get ${resource_kind} -l app=${CI_PROJECT_NAME} -o json | jq -r '.items[].spec.template.spec | .containers[],.initContainers[] | select(.image | contains($ENV.CI_PROJECT_NAME)) | .name' ))

image_updates=()
for container in ${container_names[@]} 
do
    image_updates+=("${container}=${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}:${CI_COMMIT_SHA}")
done

kubectl -n ${CI_ENVIRONMENT_NAME} set image ${resource_kind}/${CI_PROJECT_NAME} ${image_updates[@]} 