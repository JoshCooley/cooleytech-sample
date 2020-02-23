#!/usr/bin/env bash

PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_TYPE=${PROJECT_TYPE:-Dockerfile}
start_time=$(date +%s)

print_x_chars(){ head -c "$1" /dev/zero | tr \\0 "$2"; }

echo "
$(print_x_chars 64 !)
$(print_x_chars 64 !)
!!
!!  Building Docker image ...
!!
!!  Project name:     $PROJECT_NAME
!!  Git commit hash:  $(git rev-parse HEAD)
!!  Start time:       $(date -d "@$start_time")
!!
$(print_x_chars 64 !)
$(print_x_chars 64 !)
"

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

build_image(){
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
}

build_image
exit_code=$?
end_time=$(date +%s)
build_time="$(( (end_time - start_time) / 60)) minutes, \
$(( (end_time - start_time) % 60)) seconds"
if [[ $exit_code -eq 0 ]]; then
  build_result='Docker image build SUCCESS! ✅'
else
  build_result='Docker image build FAIL! ❌'
fi
echo "
$(print_x_chars 64 !)
$(print_x_chars 64 !)
!!
!!  $build_result
!!
!!  Project name:     $PROJECT_NAME
!!  Git commit hash:  $(git rev-parse HEAD)
!!  Start time:       $(date -d "@$start_time")
!!  End time:         $(date -d "@$end_time")
!!  Build time:       $build_time
!!
$(print_x_chars 64 !)
$(print_x_chars 64 !)
"

exit "$exit_code"
