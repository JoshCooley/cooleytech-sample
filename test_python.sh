#!/usr/bin/env bash

repo_name=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_NAME=${PROJECT_NAME:=repo_name}
PROJECT_TYPE=${PROJECT_TYPE:-python}
WITH_VENV=${WITH_VENV:-true}

linters=(flake8 pylint)
lint_project(){
  case $1 in
    flake8 )  # https://flake8.pycqa.org/en/latest/
      flake8 --exclude=venv .
      ;;
    pylint )  # https://www.pylint.org/
      pylint .
      ;;
    * )
      printf '\nUsage: %s LINTER\nAvailable LINTERs: %s' \
        "${FUNCNAME[0]}" "${linters[*]}"
      return 1
      ;;
  esac
}


if [[ $WITH_VENV == true ]]; then
  python -m venv venv
  . venv/bin/activate
fi
pip install -r requirements.txt
pip install -r testing-requirements.txt
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
if [[ $WITH_VENV == true ]]; then
  deactivate
  rm -rf venv
fi
