#!/bin/bash

# Script to interactively configure and run the shell setup Ansible playbook.

set -e # Exit script immediately on error

# --- Colors for Readability ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# --- Default Ansible Variables ---
ANSIBLE_EXTRA_VARS=""
DRY_RUN=false
SKIP_CONFIRM=false
PREFERRED_SHELL="/bin/bash" # Default
BASH_PROMPT_PREFERENCE="starship" # Default for Bash
ZSH_PROMPT_PREFERENCE="none" # Default for Zsh

# --- Function to Display Usage ---
usage() {
  echo -e "${GREEN}Usage:${RESET} $0 [options]"
  echo -e "${YELLOW}Options:${RESET}"
  echo "  --dry-run     Run Ansible in check mode (no changes made)."
  echo "  -y, --yes     Skip confirmation prompts (use with caution)."
  echo "  -h, --help    Show this help message."
  exit 0
}

# --- Parse Command Line Options ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -y|--yes)
      SKIP_CONFIRM=true
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

# --- Helper Functions ---
print_step() {
  echo -e "\n${BLUE}==>${RESET} ${CYAN}$1${RESET}"
}

check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo -e "${YELLOW}Command '$1' not found. Attempting basic installation...${RESET}"
    if [[ "$(uname -s)" == "Linux" ]]; then
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y
        sudo apt-get install -y "$1"
      elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y "$1"
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$1"
      elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$1"
      else
        echo -e "${RED}Error: Unsupported package manager. Please install '$1' manually.${RESET}"
        exit 1
      fi
    elif [[ "$(uname -s)" == "Darwin" ]]; then
      if command -v brew >/dev/null 2>&1; then
        brew install "$1"
      else
        echo -e "${RED}Error: Homebrew not found. Please install '$1' manually.${RESET}"
        exit 1
      fi
    else
      echo -e "${RED}Error: Unsupported OS. Please install '$1' manually.${RESET}"
      exit 1
    fi
    if ! command -v "$1" >/dev/null 2>&1; then
      echo -e "${RED}Error: Failed to install '$1'. Please install it manually and re-run the script.${RESET}"
      exit 1
    else
      echo -e "${GREEN}Dependency '$1' installed successfully.${RESET}"
    fi
  fi
}

# --- Dependency Checks ---
print_step "Checking Dependencies..."
check_command "ansible-playbook"
check_command "git"
check_command "curl"

# --- User Choices ---
print_step "Shell Configuration Choices"

# 1. Choose Shell
echo "Which shell environment would you like to set up?"
echo "  1) Bash (Customize existing, using Starship prompt)"
echo "  2) Zsh (Install Zsh, choose framework/prompt below)"
read -p "Enter choice [1-2]: " shell_choice_num

case "$shell_choice_num" in
  1)
    PREFERRED_SHELL="/bin/bash"
    ZSH_PROMPT_PREFERENCE="none" # Not applicable
    BASH_PROMPT_PREFERENCE="starship" # Default for Bash choice
    echo -e "${GREEN}Selected:${RESET} Bash with Starship (Tokyo Night theme)"
    ;;
  2)
    PREFERRED_SHELL="/usr/bin/zsh" # Adjust path if needed for your OS
    BASH_PROMPT_PREFERENCE="none" # Not applicable
    echo -e "\nWhich Zsh prompt framework do you prefer?"
    echo "  1) Oh My Zsh + Powerlevel10k (P10k)"
    echo "  2) Starship (Tokyo Night theme)"
    read -p "Enter choice [1-2]: " zsh_prompt_choice_num

    case "$zsh_prompt_choice_num" in
      1)
        ZSH_PROMPT_PREFERENCE="p10k"
        echo -e "${GREEN}Selected:${RESET} Zsh with Oh My Zsh + Powerlevel10k"
        ;;
      2)
        ZSH_PROMPT_PREFERENCE="starship"
        echo -e "${GREEN}Selected:${RESET} Zsh with Starship (Tokyo Night theme)"
        ;;
      *)
        echo -e "${RED}Invalid Zsh prompt choice. Exiting.${RESET}"
        exit 1
        ;;
    esac
    ;;
  *)
    echo -e "${RED}Invalid shell choice. Exiting.${RESET}"
    exit 1
    ;;
esac

# --- Confirmation ---
if ! $SKIP_CONFIRM; then
  print_step "Summary"
  echo "  Shell:          ${PREFERRED_SHELL}"
  echo "  Bash Prompt:    ${BASH_PROMPT_PREFERENCE}"
  echo "  Zsh Prompt:     ${ZSH_PROMPT_PREFERENCE}"
  echo "  Optional tools: Will be installed based on ansible/group_vars/all.yml"
  echo "                  (Edit that file to enable/disable Docker, K8s tools, etc.)"
  if $DRY_RUN; then
    echo -e "\n${YELLOW}Running in DRY-RUN mode. No changes will be made.${RESET}"
  fi
  read -p "Proceed with installation? (y/N) " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Aborted by user.${RESET}"
    exit 0
  fi
fi

# --- Construct Ansible Command ---
print_step "Running Ansible Playbook..."

# Add selected choices as extra vars
ANSIBLE_EXTRA_VARS="preferred_shell='${PREFERRED_SHELL}' bash_prompt_preference='${BASH_PROMPT_PREFERENCE}' zsh_prompt_preference='${ZSH_PROMPT_PREFERENCE}'"

# Base command
# Base command
ANSIBLE_CMD="ansible-playbook -i ansible/inventory/localhost ansible/custom_dev_env.yml --extra-vars \"${ANSIBLE_EXTRA_VARS}\""

# Add --ask-become-pass unless running as root or passwordless sudo is configured
if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
  ANSIBLE_CMD+=" --ask-become-pass"
fi

# Add --check for dry run
if $DRY_RUN; then
  ANSIBLE_CMD+=" --check"
fi

echo "Executing: ${ANSIBLE_CMD}"
eval $ANSIBLE_CMD # Use eval to handle quotes in extra-vars correctly
PLAYBOOK_EXIT_CODE=$?

if [ $PLAYBOOK_EXIT_CODE -ne 0 ]; then
  echo -e "${RED}Ansible playbook run failed with exit code: $PLAYBOOK_EXIT_CODE. Please check the output for errors.${RESET}"
  exit 1
fi

print_step "Installation Complete!"
echo "Please restart your terminal or run 'source ~/.bashrc' or 'exec zsh' to apply changes."
if [[ "$ZSH_PROMPT_PREFERENCE" == "p10k" ]]; then
  echo -e "${YELLOW}Tip:${RESET} You can customize Powerlevel10k further by running 'p10k configure'."
fi
if [[ "$BASH_PROMPT_PREFERENCE" == "starship" || "$ZSH_PROMPT_PREFERENCE" == "starship" ]]; then
  echo -e "${YELLOW}Tip:${RESET} Starship prompt is configured via '~/.config/starship.toml'."
fi

exit 0