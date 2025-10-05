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
        case "$command" in
          "fish")
            sudo apt-get install -y fish
            ;;
          "nu")
            # Nushell installation for Ubuntu/Debian
            sudo apt-get install -y wget
            wget -O nushell.deb https://github.com/nushell/nushell/releases/latest/download/nu-*-x86_64-linux-gnu.deb
            sudo dpkg -i nushell.deb || sudo apt-get install -f -y
            rm nushell.deb
            ;;
          *)
            sudo apt-get install -y "$command"
            ;;
        esac
      elif command_exists yum; then
        case "$command" in
          "fish")
            sudo yum install -y fish
            ;;
          "nu")
            echo -e "${YELLOW}Installing Nushell from GitHub releases...${RESET}"
            wget -O nushell.tar.gz https://github.com/nushell/nushell/releases/latest/download/nu-*-x86_64-unknown-linux-gnu.tar.gz
            tar -xzf nushell.tar.gz
            sudo mv nu-*/nu /usr/local/bin/
            rm -rf nu-* nushell.tar.gz
            ;;
          *)
            sudo yum install -y "$command"
            ;;
        esac
      elif command_exists dnf; then
        case "$command" in
          "fish")
            sudo dnf install -y fish
            ;;
          "nu")
            echo -e "${YELLOW}Installing Nushell from GitHub releases...${RESET}"
            wget -O nushell.tar.gz https://github.com/nushell/nushell/releases/latest/download/nu-*-x86_64-unknown-linux-gnu.tar.gz
            tar -xzf nushell.tar.gz
            sudo mv nu-*/nu /usr/local/bin/
            rm -rf nu-* nushell.tar.gz
            ;;
          *)
            sudo dnf install -y "$command"
            ;;
        esac
      elif command_exists pacman; then
        case "$command" in
          "fish")
            sudo pacman -S --noconfirm fish
            ;;
          "nu")
            sudo pacman -S --noconfirm nushell
            ;;
          *)
            sudo pacman -S --noconfirm "$command"
            ;;
        esac
      else
        echo -e "${RED}Error: Unsupported package manager. Please install '$command' manually.${RESET}"
        exit 1
      fi
    elif [[ "$(uname -s)" == "Darwin" ]]; then
      if command_exists brew; then
        case "$command" in
          "nu")
            brew install nushell
            ;;
          *)
            brew install "$command"
            ;;
        esac
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

# Function to list and select Starship templates
select_starship_template() {
  local templates_dir="./starship_templates"
  local template_file=""
  
  if [[ ! -d "$templates_dir" ]]; then
    echo -e "${YELLOW}Starship templates directory not found. Using default configuration.${RESET}"
    return
  fi
  
  echo -e "\nAvailable Starship templates:"
  local template_files=($(ls "$templates_dir"/*.toml 2>/dev/null | xargs -I {} basename {} .toml))
  
  if [[ ${#template_files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No Starship templates found. Using default configuration.${RESET}"
    return
  fi
  
  echo "  0) Default Starship configuration"
  for i in "${!template_files[@]}"; do
    echo "  $((i+1))) ${template_files[i]}"
  done
  
  read -p "Enter choice [0-${#template_files[@]}]: " template_choice
  
  if [[ "$template_choice" -gt 0 && "$template_choice" -le "${#template_files[@]}" ]]; then
    template_file="${template_files[$((template_choice-1))]}.toml"
    echo -e "${GREEN}Selected template:${RESET} $template_file"
    echo "$template_file"
  else
    echo -e "${GREEN}Using default Starship configuration.${RESET}"
    echo ""
  fi
}

# Function to list and select Powerlevel10k templates
select_p10k_template() {
  local templates_dir="./p10k_templates"
  local template_file=""
  
  if [[ ! -d "$templates_dir" ]]; then
    echo -e "${YELLOW}Powerlevel10k templates directory not found. Will use p10k configure wizard.${RESET}"
    return
  fi
  
  echo -e "\nAvailable Powerlevel10k templates:"
  local template_files=($(ls "$templates_dir"/p10k-*.zsh 2>/dev/null | xargs -I {} basename {} .zsh))
  
  if [[ ${#template_files[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No Powerlevel10k templates found. Will use p10k configure wizard.${RESET}"
    return
  fi
  
  echo "  0) Run p10k configure wizard (interactive setup)"
  for i in "${!template_files[@]}"; do
    local template_name="${template_files[i]#p10k-}"  # Remove p10k- prefix for display
    echo "  $((i+1))) ${template_name}"
  done
  
  read -p "Enter choice [0-${#template_files[@]}]: " template_choice
  
  if [[ "$template_choice" -gt 0 && "$template_choice" -le "${#template_files[@]}" ]]; then
    template_file="${template_files[$((template_choice-1))]}.zsh"
    echo -e "${GREEN}Selected template:${RESET} $template_file"
    echo "$template_file"
  else
    echo -e "${GREEN}Will run p10k configure wizard after installation.${RESET}"
    echo ""
  fi
}

# --- Dependency Check: Ansible ---
print_step "Checking for Ansible..."
install_dependency "ansible-playbook"

# --- User Choices ---
print_step "Shell Configuration Choices"

PREFERRED_SHELL="/bin/bash" # Default
prompt_framework="none"
starship_template=""
p10k_template=""

# 1. Choose Shell
echo "Which shell environment would you like to set up?"
echo "  1) Bash"
echo "  2) Zsh"
echo "  3) Fish"
echo "  4) Nushell"
read -p "Enter choice [1-4]: " shell_choice_num

case "$shell_choice_num" in
  1)
    PREFERRED_SHELL="/bin/bash"
    prompt_framework="starship" # Default for Bash
    echo -e "${GREEN}Selected:${RESET} Bash with Starship prompt."
    starship_template=$(select_starship_template)
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
        starship_template=$(select_starship_template)
        ;;
      2)
        prompt_framework="p10k"
        echo -e "${GREEN}Selected:${RESET} Zsh with Powerlevel10k prompt."
        p10k_template=$(select_p10k_template)
        ;;
      *)
        echo -e "${RED}Invalid Zsh prompt choice. Defaulting to no prompt framework.${RESET}"
        prompt_framework="none"
        ;;
    esac
    ;;
  3)
    PREFERRED_SHELL="/usr/bin/fish"
    install_dependency "fish"
    prompt_framework="starship"
    echo -e "${GREEN}Selected:${RESET} Fish with Starship prompt."
    starship_template=$(select_starship_template)
    ;;
  4)
    PREFERRED_SHELL="/usr/local/bin/nu"
    install_dependency "nu"
    prompt_framework="starship"
    echo -e "${GREEN}Selected:${RESET} Nushell with Starship prompt."
    starship_template=$(select_starship_template)
    ;;
  *)
    echo -e "${RED}Invalid shell choice. Defaulting to Bash.${RESET}"
    PREFERRED_SHELL="/bin/bash"
    prompt_framework="starship"
    starship_template=$(select_starship_template)
    ;;
esac

# --- Set Shell as Default (if chosen and not Bash) ---
if [[ "$PREFERRED_SHELL" != "/bin/bash" ]]; then
  shell_name=$(basename "$PREFERRED_SHELL")
  read -p "Do you want to set $shell_name as your default shell? (y/N) " set_default_shell
  if [[ "$set_default_shell" =~ ^[Yy]$ ]]; then
    if chsh -s "$PREFERRED_SHELL"; then
      echo -e "${GREEN}$shell_name set as default shell. Please log out and back in.${RESET}"
    else
      echo -e "${YELLOW}Could not set $shell_name as default. You might need to do this manually.${RESET}"
    fi
  fi
fi

# Install nerd fonts using dedicated script
install_nerd_fonts() {
    print_step "Launching font management..."
    
    if [[ -f "./manage_fonts.sh" ]]; then
        chmod +x "./manage_fonts.sh"
        ./manage_fonts.sh
    else
        echo -e "${RED}Font management script not found. Please ensure manage_fonts.sh is in the same directory.${RESET}"
    fi
}

# Call font installation
install_nerd_fonts

# --- Construct Ansible Command ---
print_step "Running Ansible Playbook..."

# Add selected choices as extra vars
ANSIBLE_EXTRA_VARS="preferred_shell='${PREFERRED_SHELL}' prompt_framework='${prompt_framework}'"

# Add starship template if selected
if [[ -n "$starship_template" ]]; then
  ANSIBLE_EXTRA_VARS+=" starship_template='${starship_template}'"
fi

# Add p10k template if selected
if [[ -n "$p10k_template" ]]; then
  ANSIBLE_EXTRA_VARS+=" p10k_template='${p10k_template}'"
fi

# Add shell installation flags
case "$shell_choice_num" in
  2)
    ANSIBLE_EXTRA_VARS+=" install_zsh=$([[ ! command_exists zsh ]] && echo "true" || echo "false")"
    ;;
  3)
    ANSIBLE_EXTRA_VARS+=" install_fish=$([[ ! command_exists fish ]] && echo "true" || echo "false")"
    ;;
  4)
    ANSIBLE_EXTRA_VARS+=" install_nushell=$([[ ! command_exists nu ]] && echo "true" || echo "false")"
    ;;
esac

# Base command
ANSIBLE_CMD="ansible-playbook -i ansible/inventory/localhost ansible/custom_dev_env.yml --extra-vars \"${ANSIBLE_EXTRA_VARS}\""

# Add --ask-become-pass unless running as root or passwordless sudo is configured
if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
  ANSIBLE_CMD+=" --ask-become-pass"
fi

echo "Executing: ${ANSIBLE_CMD}"
eval $ANSIBLE_CMD # Use eval to handle quotes in extra-vars correctly
PLAYBOOK_EXIT_CODE=$?

if [ $PLAYBOOK_EXIT_CODE -ne 0 ]; then
  echo -e "${RED}Ansible playbook run failed with exit code: $PLAYBOOK_EXIT_CODE. Please check the output for errors.${RESET}"
  exit 1
fi

print_step "Installation Complete!"
echo "Please restart your terminal or run the appropriate command to apply changes:"
case "$shell_choice_num" in
  1)
    echo "  source ~/.bashrc"
    ;;
  2)
    echo "  exec zsh"
    ;;
  3)
    echo "  exec fish"
    ;;
  4)
    echo "  exec nu"
    ;;
esac

if [[ "$prompt_framework" == "p10k" ]]; then
  if [[ -n "$p10k_template" ]]; then
    echo -e "${YELLOW}Your selected Powerlevel10k template:${RESET} $p10k_template"
    echo -e "${YELLOW}Note:${RESET} The template will be copied to ~/.p10k.zsh"
  else
    echo -e "${YELLOW}Tip:${RESET} Run 'p10k configure' to set up your Powerlevel10k theme interactively."
  fi
  echo -e "${YELLOW}Note:${RESET} Oh My Zsh and Powerlevel10k will be installed if not already present."
fi
if [[ "$prompt_framework" == "starship" ]]; then
  echo -e "${YELLOW}Tip:${RESET} Starship prompt is configured via '~/.config/starship.toml'."
  if [[ -n "$starship_template" ]]; then
    echo -e "${YELLOW}Your selected template:${RESET} $starship_template"
  fi
fi

exit 0