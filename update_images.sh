#!/usr/bin/env bash

set -euo pipefail

# stop script not just the current command
trap "exit" SIGINT SIGTERM

namespace="${CI_ENVIRONMENT_NAME}"

while [[ "${1-}" =~ ^- && ! "${1-}" == "--" ]]; do 
  case $1 in
    -n | --namespace )
      shift
      namespace="$1"
      ;;
  esac
  shift
done

if [[ "${1-}" == '--' ]]; then 
  shift
fi

resources=$(kubectl -n "${namespace}" get deployment,daemonset,statefulset -l dliver.com/project="${CI_PROJECT_NAME}" -o json)
item_count=$(jq -r '.items | length' <<< "${resources}") 

if [[ ${item_count} == 0 ]]; then
    echo "Resource for project '${CI_PROJECT_NAME}' not found"
    exit 1
fi

for (( i = 0; i < item_count; i++ )); do
    resource=$(jq -r ".items[$i]" <<< "${resources}")
    resource_identifier=$(jq -r '.kind + "/" + .metadata.name' <<< "${resource}")
    mapfile -t container_names < <(jq -r '.spec.template.spec | .containers[],.initContainers[]? | select(.image | contains($ENV.CI_PROJECT_NAME)) | .name' <<< "${resource}")
    
    image_updates=()
    for container in "${container_names[@]}" 
    do
        image_updates+=("${container}=${CI_REGISTRY}/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}:${CI_COMMIT_SHA}")
    done

    kubectl -n "${namespace}" set image "${resource_identifier}" "${image_updates[@]}" 
done