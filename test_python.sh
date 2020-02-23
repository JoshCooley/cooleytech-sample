#!/usr/bin/env bash

repo_name=$(basename "$(git rev-parse --show-toplevel)")
PROJECT_NAME=${PROJECT_NAME:=repo_name}
PROJECT_TYPE=${PROJECT_TYPE:-python}
WITH_VENV=${WITH_VENV:-true}

linters=(flake8 pylint)
lint_project(){
  case $1 in
    # https://flake8.pycqa.org/en/latest/, https://www.pylint.org/
    flake8 | pylint )
      $1 .
      ;;
    * )
      printf '\nUsage: %s LINTER\nAvailable LINTERs: %s' \
        "${FUNCNAME[0]}" "${linters[*]}"
      return 1
      ;;
  esac
}

testers=(web)
test_project(){
  case $1 in
    web)
      echo 1
      PORT=1234 python -um . & pid=$!
      echo 2
      curl --silent --show-error http://localhost:1234/
      exit_code=$?
      echo 4
      kill "$pid"
      echo 5
      return "$exit_code"
      echo 6
      ;;
    * )
      printf '\nUsage: %s TESTER\nAvailable TESTER: %s' \
        "${FUNCNAME[0]}" "${testers[*]}"
      return 1
      ;;
  esac
}

if [[ $WITH_VENV == true ]]; then
  venv=$(mktemp -d)
  echo "Creating build venv $venv"
  python -m venv "$venv"
  echo 'Activating venv'
  . "$venv/bin/activate"
fi

pip install -r requirements.txt -r testing-requirements.txt
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
for tester in "${testers[@]}"; do
  printf '%-50s' "Testing $PROJECT_TYPE with $tester ... "
  if test=$(test_project "$tester" 2>&1); then
    echo 'PASSED ✅'
  else
    echo 'FAILED ❌'
    echo "$test"
    exit 1
  fi
done

if [[ $WITH_VENV == true ]]; then
  echo "Deactivating venv $venv"
  deactivate
  echo 'Removing venv'
  rm -rf "$venv"
fi
