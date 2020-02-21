#!/usr/bin/env bash

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_TYPE=${PROJECT_TYPE:-Dockerfile}

linters=(dockerfilelint hadolint)
lint_project(){
  case $1 in
    dockerfilelint )  # https://github.com/replicatedhq/dockerfilelint
      docker run -v "$(pwd)"/Dockerfile:/Dockerfile \
        replicated/dockerfilelint /Dockerfile
      ;;
    hadolint )  # https://github.com/hadolint/hadolint
      docker run --rm -i hadolint/hadolint < Dockerfile
      ;;
    * )
      printf '\nUsage: %s LINTER\nAvailable LINTERs: %s' \
        "${FUNCNAME[0]}" "${linters[*]}"
      return 1
      ;;
  esac
}

for linter in "${linters[@]}"; do
  printf '%-50s' "Linting $PROJECT_TYPE with $linter ... "
  if lint=$(lint_project "$linter" 2>&1); then
    echo 'PASSED ✅'
  else
    echo 'FAILED ❌'
    echo "$lint"
    exit 1
  fi
done

docker build . \
  --build-arg PROJECT_NAME="$PROJECT_NAME" \
  --tag "$PROJECT_NAME":build
