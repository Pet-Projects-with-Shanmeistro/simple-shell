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

# --- Helper Functions ---
print_step() {
  echo -e "\n${BLUE}==>${RESET} ${CYAN}$1${RESET}"
}

command_exists () {
  command -v "$1" >/dev/null 2>&1
}

install_dependency() {
  local command="$1"
  if ! command_exists "$command"; then
    echo -e "${YELLOW}Command '$command' not found. Attempting basic installation...${RESET}"
    if [[ "$(uname -s)" == "Linux" ]]; then
      if command_exists apt-get; then
        sudo apt-get update -y
        sudo apt-get install -y "$command"
      elif command_exists yum; then
        sudo yum install -y "$command"
      elif command_exists dnf; then
        sudo dnf install -y "$command"
      elif command_exists pacman; then
        sudo pacman -S --noconfirm "$command"
      else
        echo -e "${RED}Error: Unsupported package manager. Please install '$command' manually.${RESET}"
        exit 1
      fi
    elif [[ "$(uname -s)" == "Darwin" ]]; then
      if command_exists brew; then
        brew install "$command"
      else
        echo -e "${RED}Error: Homebrew not found. Please install '$command' manually.${RESET}"
        exit 1
      fi
    else
      echo -e "${RED}Error: Unsupported OS. Please install '$command' manually.${RESET}"
      exit 1
    fi
    if ! command_exists "$command"; then
      echo -e "${RED}Error: Failed to install '$command'. Please install it manually and re-run the script.${RESET}"
      exit 1
    else
      echo -e "${GREEN}Dependency '$command' installed successfully.${RESET}"
    fi
  fi
}

# --- Dependency Check: Ansible ---
print_step "Checking for Ansible..."
install_dependency "ansible-playbook"

# --- User Choices ---
print_step "Shell Configuration Choices"

PREFERRED_SHELL="/bin/bash" # Default
prompt_framework="none"

# 1. Choose Shell
echo "Which shell environment would you like to set up?"
echo "  1) Bash"
echo "  2) Zsh"
read -p "Enter choice [1-2]: " shell_choice_num

case "$shell_choice_num" in
  1)
    PREFERRED_SHELL="/bin/bash"
    prompt_framework="starship" # Default for Bash
    echo -e "${GREEN}Selected:${RESET} Bash with Starship prompt."
    ;;
  2)
    PREFERRED_SHELL="/usr/bin/zsh" # Adjust path if needed for your OS
    install_dependency "zsh" # Ensure Zsh is installed

    echo -e "\nWhich Zsh prompt framework do you prefer?"
    echo "  1) Starship"
    echo "  2) Powerlevel10k (requires Oh My Zsh)"
    read -p "Enter choice [1-2]: " zsh_prompt_choice_num

    case "$zsh_prompt_choice_num" in
      1)
        prompt_framework="starship"
        echo -e "${GREEN}Selected:${RESET} Zsh with Starship prompt."
        ;;
      2)
        prompt_framework="p10k"
        echo -e "${GREEN}Selected:${RESET} Zsh with Powerlevel10k prompt."
        ;;
      *)
        echo -e "${RED}Invalid Zsh prompt choice. Defaulting to no prompt framework.${RESET}"
        prompt_framework="none"
        ;;
    esac
    ;;
  *)
    echo -e "${RED}Invalid shell choice. Defaulting to Bash.${RESET}"
    PREFERRED_SHELL="/bin/bash"
    prompt_framework="starship"
    ;;
esac

# --- Set Zsh as Default (if chosen) ---
if [[ "$PREFERRED_SHELL" == "/usr/bin/zsh" ]]; then
  read -p "Do you want to set Zsh as your default shell? (y/N) " set_default_zsh
  if [[ "$set_default_zsh" =~ ^[Yy]$ ]]; then
    if chsh -s "$(which zsh)"; then
      echo -e "${GREEN}Zsh set as default shell. Please log out and back in.${RESET}"
    else
      echo -e "${YELLOW}Could not set Zsh as default. You might need to do this manually.${RESET}"
    fi
  fi
fi

# Replace the font installation section in install_custom_shell.sh with:

# Install nerd fonts using dedicated script
install_nerd_fonts() {
    print_info "Launching font management..."
    
    if [[ -f "./manage_fonts.sh" ]]; then
        chmod +x "./manage_fonts.sh"
        ./manage_fonts.sh
    else
        print_error "Font management script not found. Please ensure manage_fonts.sh is in the same directory."
    fi
}

# --- Construct Ansible Command ---
print_step "Running Ansible Playbook..."

# Add selected choices as extra vars
ANSIBLE_EXTRA_VARS="preferred_shell='${PREFERRED_SHELL}' prompt_framework='${prompt_framework}' install_zsh=$([[ "$PREFERRED_SHELL" == "/usr/bin/zsh" ]] && [[ ! command_exists zsh ]] && echo "true" || echo "false")"

# Base command
ANSIBLE_CMD="ansible-playbook -i ansible/inventory/localhost ansible/custom_dev_env.yml --extra-vars \"${ANSIBLE_EXTRA_VARS}\""

# Add --ask-become-pass unless running as root or passwordless sudo is configured
if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
  ANSIBLE_CMD+=" --ask-become-become-pass"
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
if [[ "$prompt_framework" == "p10k" ]]; then
  echo -e "${YELLOW}Tip:${RESET} You will need to install Oh My Zsh and the Powerlevel10k theme separately if they are not already present."
fi
if [[ "$prompt_framework" == "starship" ]]; then
  echo -e "${YELLOW}Tip:${RESET} Starship prompt is configured via '~/.config/starship.toml'."
fi

exit 0