#!/bin/bash

set -e  # Exit script immediately on error

# Colors for better readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Default extra variables
EXTRA_VARS="update_zsh_from_repo=false update_configs=false"
DRY_RUN=false

# Function to display usage
usage() {
  echo -e "${GREEN}Usage:${RESET} $0 [options]"
  echo -e "${YELLOW}Options:${RESET}"
  echo "  --extra-vars \"key=value key2=value2\"  Specify extra Ansible variables."
  echo "  --dry-run                              Run Ansible in check mode (does not make changes)."
  echo "  -h, --help                             Show this help message."
  exit 0
}

# Parse optional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --extra-vars)
      EXTRA_VARS="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo -e "${RED}Unknown option:${RESET} $1"
      usage
      ;;
  esac
done

# Check if Ansible is installed
if ! command -v ansible >/dev/null 2>&1; then
  echo -e "${YELLOW}Ansible not found. Installing...${RESET}"
  sudo apt update -y && sudo apt install -y ansible
else
  echo -e "${GREEN}Ansible is already installed.${RESET}"
fi

# Confirm before overwriting configs (optional)
if [[ "$EXTRA_VARS" == *"update_configs=true"* ]]; then
  read -p "You are about to overwrite existing configurations. Continue? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted: Configurations will not be updated.${RESET}"
    EXTRA_VARS=${EXTRA_VARS//update_configs=true/update_configs=false}  # Prevent overwriting
  fi
fi

# Run Ansible playbook
echo -e "${GREEN}Running Ansible playbook with variables:${RESET} $EXTRA_VARS"
if $DRY_RUN; then
  ansible-playbook ansible/playbook.yml --ask-become-pass --extra-vars "$EXTRA_VARS" --check
else
  ansible-playbook ansible/playbook.yml --ask-become-pass --extra-vars "$EXTRA_VARS"
fi
