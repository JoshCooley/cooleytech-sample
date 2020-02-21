#!/usr/bin/env bash

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")

linters=(dockerfilelint hadolint)
lint_dockerfile(){
  case $1 in
    dockerfilelint )  # https://github.com/replicatedhq/dockerfilelint
      docker run -v "$(pwd)"/Dockerfile:/Dockerfile \
        replicated/dockerfilelint /Dockerfile
      ;;
    hadolint )  # https://github.com/hadolint/hadolint
      docker run --rm -i hadolint/hadolint < Dockerfile
      ;;
    * )
      printf '\nUsage: link_dockerfile LINTER\nAvailable LINTERs: %s' "${linters[*]}"
      return 1
      ;;
  esac
}

for linter in "${linters[@]}"; do
  echo -n "Linting Dockerfile with $linter ... "
  if lint=$(lint_dockerfile "$linter" 2>&1); then
    echo 'PASSED ✅'
    docker build . \
      --build-arg PROJECT_NAME="$PROJECT_NAME" \
      --tag "$PROJECT_NAME":build
  else
    echo 'FAILED ❌'
    echo "$lint"
    exit 1
  fi
done
