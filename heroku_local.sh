#!/usr/bin/env bash

WITH_VENV=${WITH_VENV:-true}

if [[ $WITH_VENV == true ]]; then
  venv=$(mktemp -d)
  echo "Creating build venv $venv"
  python -m venv "$venv"
  echo 'Activating venv'
  . "$venv/bin/activate"
fi
pip install -r requirements.txt -r testing-requirements.txt
heroku local
if [[ $WITH_VENV == true ]]; then
  echo "Deactivating venv $venv"
  deactivate
  echo 'Removing venv'
  rm -rf "$venv"
fi