#!/bin/bash

# Custom Shell Environment Setup Script
# Supports Ubuntu 20.04+, macOS with comprehensive shell and framework options

set -e # Exit script immediately on error

# --- Colors for Readability ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

# --- Helper Functions ---
print_header() {
  echo -e "\n${BOLD}${BLUE}================================================================${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${BLUE}================================================================${RESET}\n"
}

print_step() {
  echo -e "\n${BLUE}==>${RESET} ${CYAN}$1${RESET}"
}

print_success() {
  echo -e "${GREEN}✓${RESET} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${RESET} $1"
}

print_error() {
  echo -e "${RED}✗${RESET} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${RESET} $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to detect OS and version
detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
  elif [[ "$(uname -s)" == "Linux" ]]; then
    if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      if [[ "$ID" == "ubuntu" ]]; then
        # Check Ubuntu version
        version_major=$(echo "$VERSION_ID" | cut -d. -f1)
        version_minor=$(echo "$VERSION_ID" | cut -d. -f2)
        if [[ "$version_major" -ge 20 ]]; then
          echo "ubuntu"
        else
          echo "unsupported_ubuntu"
        fi
      else
        echo "unsupported_linux"
      fi
    else
      echo "unsupported_linux"
    fi
  else
    echo "unsupported"
  fi
}

# Function to check for existing shell configurations
check_existing_setup() {
  local has_existing=false
  local configs_found=()
  
  print_step "Checking for existing shell configurations..."
  
  # Check for existing config files
  [[ -f ~/.zshrc ]] && configs_found+=(".zshrc") && has_existing=true
  [[ -f ~/.bashrc ]] && configs_found+=(".bashrc") && has_existing=true
  [[ -f ~/.config/fish/config.fish ]] && configs_found+=("fish config") && has_existing=true
  [[ -f ~/.config/nushell/config.nu ]] && configs_found+=("nushell config") && has_existing=true
  [[ -d ~/.oh-my-zsh ]] && configs_found+=("Oh My Zsh") && has_existing=true
  [[ -f ~/.p10k.zsh ]] && configs_found+=("Powerlevel10k config") && has_existing=true
  [[ -f ~/.config/starship.toml ]] && configs_found+=("Starship config") && has_existing=true
  
  if [[ "$has_existing" == true ]]; then
    print_warning "Found existing shell configurations:"
    for config in "${configs_found[@]}"; do
      echo "  • $config"
    done
    echo ""
    echo "Options:"
    echo "  1) Update/modify existing setup (with backup)"
    echo "  2) Clean install (backup existing configs first)"
    echo "  3) Exit without changes"
    echo ""
    read -p "Enter your choice [1-3]: " existing_choice
    
    case "$existing_choice" in
      1)
        SETUP_MODE="update"
        print_success "Will update existing setup with backup"
        ;;
      2)
        SETUP_MODE="clean"
        print_success "Will perform clean install with backup"
        ;;
      3)
        print_info "Exiting without changes"
        exit 0
        ;;
      *)
        print_warning "Invalid choice. Defaulting to update mode"
        SETUP_MODE="update"
        ;;
    esac
  else
    SETUP_MODE="new"
    print_success "No existing configurations found. Proceeding with fresh install"
  fi
}

# Function to install Ansible if needed
ensure_ansible() {
  print_step "Checking for Ansible..."
  
  if command_exists ansible-playbook; then
    local version=$(ansible --version | head -n1 | awk '{print $2}')
    print_success "Ansible $version is already installed"
    return 0
  fi
  
  print_warning "Ansible not found. Installing..."
  
  local os=$(detect_os)
  case "$os" in
    ubuntu)
      print_info "Installing Ansible on Ubuntu..."
      sudo apt-get update -qq
      sudo apt-get install -y software-properties-common
      sudo add-apt-repository --yes --update ppa:ansible/ansible
      sudo apt-get install -y ansible
      ;;
    macos)
      print_info "Installing Ansible on macOS..."
      if command_exists brew; then
        brew install ansible
      else
        print_error "Homebrew not found. Please install Homebrew first:"
        print_info "Visit: https://brew.sh"
        exit 1
      fi
      ;;
    unsupported_ubuntu)
      print_error "Ubuntu version is too old. This script requires Ubuntu 20.04 or newer."
      exit 1
      ;;
    unsupported_linux)
      print_error "This script only supports Ubuntu 20.04+ on Linux."
      exit 1
      ;;
    *)
      print_error "Unsupported operating system."
      exit 1
      ;;
  esac
  
  if command_exists ansible-playbook; then
    print_success "Ansible installed successfully"
  else
    print_error "Failed to install Ansible"
    exit 1
  fi
}

# Function to select shell
select_shell() {
  print_header "Shell Selection"
  
  echo "Choose your preferred shell:"
  echo ""
  echo "  ${BOLD}1) Bash${RESET}"
  echo "     • Default shell on most systems"
  echo "     • Reliable and well-documented"
  echo "     • Great for scripting and automation"
  echo "     • Works with Starship prompt"
  echo ""
  echo "  ${BOLD}2) Zsh${RESET} ${GREEN}(Recommended)${RESET}"
  echo "     • Feature-rich with excellent tab completion"
  echo "     • Compatible with Bash scripts"
  echo "     • Extensive customization options"
  echo "     • Works with Oh My Zsh, Powerlevel10k, Starship, and more"
  echo ""
  echo "  ${BOLD}3) Fish${RESET}"
  echo "     • User-friendly with smart autosuggestions"
  echo "     • Syntax highlighting out of the box"
  echo "     • Web-based configuration"
  echo "     • Modern and intuitive design"
  echo ""
  echo "  ${BOLD}4) Nushell${RESET}"
  echo "     • Modern shell with structured data support"
  echo "     • Built-in commands for data manipulation"
  echo "     • Cross-platform consistency"
  echo "     • Perfect for data analysis and DevOps"
  echo ""
  
  read -p "Enter your choice [1-4]: " shell_choice
  
  case "$shell_choice" in
    1)
      PREFERRED_SHELL="/bin/bash"
      SHELL_NAME="Bash"
      AVAILABLE_FRAMEWORKS=("starship")
      ;;
    2)
      PREFERRED_SHELL="/usr/bin/zsh"
      SHELL_NAME="Zsh"
      AVAILABLE_FRAMEWORKS=("oh-my-zsh" "oh-my-posh" "starship" "spaceship" "zim" "prezto")
      ;;
    3)
      PREFERRED_SHELL="/usr/bin/fish"
      SHELL_NAME="Fish"
      AVAILABLE_FRAMEWORKS=("starship" "oh-my-posh")
      ;;
    4)
      PREFERRED_SHELL="/usr/local/bin/nu"
      SHELL_NAME="Nushell"
      AVAILABLE_FRAMEWORKS=("starship" "oh-my-posh")
      ;;
    *)
      print_warning "Invalid choice. Defaulting to Zsh"
      PREFERRED_SHELL="/usr/bin/zsh"
      SHELL_NAME="Zsh"
      AVAILABLE_FRAMEWORKS=("oh-my-zsh" "oh-my-posh" "starship" "spaceship" "zim" "prezto")
      ;;
  esac
  
  print_success "Selected: $SHELL_NAME"
}

# Function to select framework/prompt
select_framework() {
  print_header "Framework & Prompt Selection"
  
  echo "Available frameworks for $SHELL_NAME:"
  echo ""
  
  local framework_descriptions=(
    "oh-my-zsh:Oh My Zsh with Powerlevel10k:Feature-rich Zsh framework with beautiful prompts:Highly customizable, large community, many plugins"
    "oh-my-posh:Oh My Posh:Cross-shell prompt engine:Modern themes, works across shells, JSON configuration"
    "starship:Starship:Fast, cross-shell prompt:Minimal setup, blazing fast, language-aware"
    "spaceship:Spaceship ZSH:Minimalistic Zsh prompt:Clean design, Git integration, customizable sections"
    "zim:Zim:Modular Zsh framework:Fast startup, modular design, easy to configure"
    "prezto:Prezto:Zsh configuration framework:Sane defaults, extensive modules, well-documented"
  )
  
  local counter=1
  local valid_frameworks=()
  
  for framework in "${AVAILABLE_FRAMEWORKS[@]}"; do
    for desc in "${framework_descriptions[@]}"; do
      IFS=':' read -r fw_name fw_title fw_desc fw_features <<< "$desc"
      if [[ "$fw_name" == "$framework" ]]; then
        echo "  ${BOLD}$counter) $fw_title${RESET}"
        echo "     • $fw_desc"
        echo "     • $fw_features"
        echo ""
        valid_frameworks+=("$framework")
        ((counter++))
        break
      fi
    done
  done
  
  read -p "Enter your choice [1-${#valid_frameworks[@]}]: " framework_choice
  
  if [[ "$framework_choice" -ge 1 && "$framework_choice" -le "${#valid_frameworks[@]}" ]]; then
    PROMPT_FRAMEWORK="${valid_frameworks[$((framework_choice-1))]}"
  else
    print_warning "Invalid choice. Defaulting to starship"
    PROMPT_FRAMEWORK="starship"
  fi
  
  # Set theme selection based on framework
  case "$PROMPT_FRAMEWORK" in
    "oh-my-zsh")
      PROMPT_FRAMEWORK="p10k"  # Internal framework name
      select_p10k_template
      ;;
    "starship")
      select_starship_template
      ;;
    *)
      print_info "Selected framework: $PROMPT_FRAMEWORK"
      THEME_TEMPLATE=""
      ;;
  esac
  
  print_success "Framework: $PROMPT_FRAMEWORK"
}

# Function to select Starship template
select_starship_template() {
  local templates_dir="./starship_templates"
  
  if [[ ! -d "$templates_dir" ]]; then
    print_warning "Starship templates directory not found. Using default configuration."
    THEME_TEMPLATE=""
    return
  fi
  
  echo ""
  echo "Available Starship themes:"
  local template_files=($(ls "$templates_dir"/*.toml 2>/dev/null | xargs -I {} basename {} .toml))
  
  if [[ ${#template_files[@]} -eq 0 ]]; then
    print_warning "No Starship templates found. Using default configuration."
    THEME_TEMPLATE=""
    return
  fi
  
  echo "  0) Default Starship configuration"
  for i in "${!template_files[@]}"; do
    echo "  $((i+1))) ${template_files[i]}"
  done
  
  read -p "Enter choice [0-${#template_files[@]}]: " template_choice
  
  if [[ "$template_choice" -gt 0 && "$template_choice" -le "${#template_files[@]}" ]]; then
    THEME_TEMPLATE="${template_files[$((template_choice-1))]}"
    print_success "Selected theme: $THEME_TEMPLATE"
  else
    print_info "Using default Starship configuration"
    THEME_TEMPLATE=""
  fi
}

# Function to select Powerlevel10k template
select_p10k_template() {
  local templates_dir="./p10k_templates"
  
  if [[ ! -d "$templates_dir" ]]; then
    print_warning "Powerlevel10k templates directory not found. Will use p10k configure wizard."
    THEME_TEMPLATE=""
    return
  fi
  
  echo ""
  echo "Available Powerlevel10k themes:"
  local template_files=($(ls "$templates_dir"/p10k-*.zsh 2>/dev/null | xargs -I {} basename {} .zsh))
  
  if [[ ${#template_files[@]} -eq 0 ]]; then
    print_warning "No Powerlevel10k templates found. Will use p10k configure wizard."
    THEME_TEMPLATE=""
    return
  fi
  
  echo "  0) Run p10k configure wizard (interactive setup)"
  for i in "${!template_files[@]}"; do
    local template_name="${template_files[i]#p10k-}"
    echo "  $((i+1))) ${template_name}"
  done
  
  read -p "Enter choice [0-${#template_files[@]}]: " template_choice
  
  if [[ "$template_choice" -gt 0 && "$template_choice" -le "${#template_files[@]}" ]]; then
    THEME_TEMPLATE="${template_files[$((template_choice-1))]}"
    print_success "Selected theme: $THEME_TEMPLATE"
  else
    print_info "Will run p10k configure wizard after installation"
    THEME_TEMPLATE=""
  fi
}

# Function to recommend fonts
recommend_fonts() {
  print_header "Font Recommendations"
  
  local recommended_fonts=()
  
  case "$PROMPT_FRAMEWORK" in
    "p10k")
      recommended_fonts=("MesloLGS" "Hack" "FiraCode" "CascadiaCode")
      print_info "For Powerlevel10k, these fonts work excellently:"
      ;;
    "starship")
      recommended_fonts=("JetBrainsMono" "FiraCode" "CascadiaCode" "Hack")
      print_info "For Starship, these fonts provide great symbol support:"
      ;;
    *)
      recommended_fonts=("JetBrainsMono" "FiraCode" "CascadiaCode")
      print_info "For $PROMPT_FRAMEWORK, these fonts are recommended:"
      ;;
  esac
  
  for font in "${recommended_fonts[@]}"; do
    echo "  • $font Nerd Font"
  done
  
  echo ""
  print_info "These fonts will be available for installation in the next step."
}

# Function to manage optional tools
manage_optional_tools() {
  print_header "Optional Tools Management"
  
  echo "Would you like to configure optional development tools?"
  echo "(Docker, Kubernetes, Python tools, Node.js, etc.)"
  echo ""
  echo "  1) Yes, configure optional tools now"
  echo "  2) Skip for now (can run later with ./manage_optional_tools.sh)"
  echo ""
  
  read -p "Enter your choice [1-2]: " tools_choice
  
  case "$tools_choice" in
    1)
      if [[ -f "./manage_optional_tools.sh" ]]; then
        print_info "Launching optional tools configuration..."
        chmod +x "./manage_optional_tools.sh"
        ./manage_optional_tools.sh
      else
        print_error "manage_optional_tools.sh not found in current directory"
      fi
      ;;
    2)
      print_info "Skipping optional tools. You can run ./manage_optional_tools.sh later."
      ;;
    *)
      print_warning "Invalid choice. Skipping optional tools configuration."
      ;;
  esac
}

# Function to run font management
run_font_management() {
  print_header "Font Installation"
  
  if [[ -f "./manage_fonts.sh" ]]; then
    print_info "Launching font management..."
    chmod +x "./manage_fonts.sh"
    ./manage_fonts.sh
  else
    print_error "manage_fonts.sh not found. Please ensure it's in the same directory."
    print_info "You can install fonts manually or download the script later."
  fi
}

# Function to build and run Ansible command
run_ansible_playbook() {
  print_header "Installing Shell Environment"
  
  # Build extra vars
  local extra_vars="preferred_shell='${PREFERRED_SHELL}' prompt_framework='${PROMPT_FRAMEWORK}' setup_mode='${SETUP_MODE}'"
  
  # Add theme template if selected
  if [[ -n "$THEME_TEMPLATE" ]]; then
    if [[ "$PROMPT_FRAMEWORK" == "p10k" ]]; then
      extra_vars+=" p10k_template='${THEME_TEMPLATE}'"
    elif [[ "$PROMPT_FRAMEWORK" == "starship" ]]; then
      extra_vars+=" starship_template='${THEME_TEMPLATE}'"
    fi
  fi
  
  # Add shell installation flags
  case "$SHELL_NAME" in
    "Zsh")
      extra_vars+=" install_zsh=true"
      ;;
    "Fish")
      extra_vars+=" install_fish=true"
      ;;
    "Nushell")
      extra_vars+=" install_nushell=true"
      ;;
  esac
  
  print_info "Running Ansible playbook with configuration..."
  print_info "Shell: $SHELL_NAME"
  print_info "Framework: $PROMPT_FRAMEWORK"
  if [[ -n "$THEME_TEMPLATE" ]]; then
    print_info "Theme: $THEME_TEMPLATE"
  fi
  print_info "Setup mode: $SETUP_MODE"
  
  # Build and execute command
  local ansible_cmd="ansible-playbook -i ansible/inventory/localhost ansible/custom_dev_env.yml --extra-vars \"${extra_vars}\""
  
  # Add sudo prompt if needed
  if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
    ansible_cmd+=" --ask-become-pass"
  fi
  
  print_info "Executing: $ansible_cmd"
  
  if eval "$ansible_cmd"; then
    print_success "Ansible playbook completed successfully!"
    return 0
  else
    print_error "Ansible playbook failed. Please check the output above."
    return 1
  fi
}

# Function to show post-installation instructions
show_completion_message() {
  print_header "Installation Complete!"
  
  print_success "Your $SHELL_NAME environment with $PROMPT_FRAMEWORK has been set up!"
  
  echo ""
  echo "Next steps:"
  echo ""
  
  case "$SHELL_NAME" in
    "Bash")
      echo "  1. Restart your terminal or run: ${CYAN}source ~/.bashrc${RESET}"
      ;;
    "Zsh")
      echo "  1. Restart your terminal or run: ${CYAN}exec zsh${RESET}"
      if [[ "$PREFERRED_SHELL" != "$(echo $SHELL)" ]]; then
        echo "  2. Set Zsh as default: ${CYAN}chsh -s /usr/bin/zsh${RESET}"
      fi
      ;;
    "Fish")
      echo "  1. Restart your terminal or run: ${CYAN}exec fish${RESET}"
      if [[ "$PREFERRED_SHELL" != "$(echo $SHELL)" ]]; then
        echo "  2. Set Fish as default: ${CYAN}chsh -s /usr/bin/fish${RESET}"
      fi
      ;;
    "Nushell")
      echo "  1. Start Nushell: ${CYAN}nu${RESET}"
      echo "  2. Consider adding nu to your PATH if not already done"
      ;;
  esac
  
  if [[ "$PROMPT_FRAMEWORK" == "p10k" ]] && [[ -z "$THEME_TEMPLATE" ]]; then
    echo "  3. Configure Powerlevel10k: ${CYAN}p10k configure${RESET}"
  fi
  
  echo ""
  print_info "Additional configurations:"
  echo "  • Fonts: Install recommended Nerd Fonts for best experience"
  echo "  • Tools: Run ${CYAN}./manage_optional_tools.sh${RESET} to add development tools"
  echo "  • Themes: Check the templates directories for more customization options"
  
  echo ""
  print_success "Enjoy your new shell environment! 🚀"
}

# Main execution flow
main() {
  print_header "Custom Shell Environment Setup"
  
  # Validate OS support
  local os=$(detect_os)
  case "$os" in
    ubuntu|macos)
      print_success "Detected supported OS: $os"
      ;;
    unsupported_ubuntu)
      print_error "Ubuntu version too old. This script requires Ubuntu 20.04 or newer."
      exit 1
      ;;
    *)
      print_error "Unsupported OS. This script supports Ubuntu 20.04+ and macOS only."
      exit 1
      ;;
  esac
  
  # Check if running from correct directory
  if [[ ! -f "ansible/custom_dev_env.yml" ]]; then
    print_error "Error: Must be run from the project root directory"
    print_info "Please cd to the simple-shell directory and run: ./install_custom_shell.sh"
    exit 1
  fi
  
  # Main workflow
  check_existing_setup
  ensure_ansible
  select_shell
  select_framework
  recommend_fonts
  run_font_management
  manage_optional_tools
  
  if run_ansible_playbook; then
    show_completion_message
  else
    print_error "Installation failed. Please check the errors above and try again."
    exit 1
  fi
}

# Handle script arguments
case "${1:-}" in
  --help|-h)
    echo "Custom Shell Environment Setup"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h     Show this help message"
    echo "  --check        Run in check mode (show what would be done)"
    echo ""
    echo "Supported:"
    echo "  • Ubuntu 20.04+"
    echo "  • macOS"
    echo ""
    echo "Shells: Bash, Zsh, Fish, Nushell"
    echo "Frameworks: Oh My Zsh, Oh My Posh, Starship, Spaceship, Zim, Prezto"
    exit 0
    ;;
  --check)
    CHECK_MODE="--check"
    print_info "Running in CHECK MODE - no changes will be made"
    ;;
esac

# Run main function
main "$@"