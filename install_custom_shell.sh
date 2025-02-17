#!/bin/bash

# Update packages
sudo apt update -y

# Check and install Ansible
if ! command -v ansible >/dev/null; then
  echo "Ansible not found. Installing..."
  sudo apt install -y ansible
else
  echo "Ansible is already installed."
fi

# Parse optional extra variables
EXTRA_VARS="update_zsh_from_repo=false update_configs=false"
while [[ $# -gt 0 ]]; do
  case $1 in
    --extra-vars)
      EXTRA_VARS="$2"
      shift
      ;;
  esac
  shift
done

ansible-playbook ansible/playbook.yml --ask-become-pass --extra-vars "$EXTRA_VARS"
