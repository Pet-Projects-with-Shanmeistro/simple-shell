#!/bin/bash

# Script to manage optional development tools.

set -e # Exit script immediately on error

# --- Colors for Readability ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# --- Helper Functions ---
print_header() {
  echo -e "\n${BLUE}==>${RESET} ${CYAN}$1${RESET}"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Version and Update Helpers ---
version_package() {
  local package="$1"
  if command_exists "$package"; then
    echo -e "${YELLOW}Checking version for '$package'...${RESET}"
    "$package" --version 2>&1 | head -n 1
  else
    echo -e "${RED}Error: '$package' is not installed.${RESET}"
    return 1
  fi
}

update_package() {
  local package="$1"
  if [[ "$(uname -s)" == "Linux" ]] && command_exists apt-get; then
    echo -e "${YELLOW}Attempting to update '$package'...${RESET}"
    sudo apt-get update
    sudo apt-get install --only-upgrade -y "$package"
    echo -e "${GREEN}'$package' updated.${RESET}"
  else
    echo -e "${RED}Error: Update not supported or not Linux (apt-get).${RESET}"
    return 1
  fi
}

# --- Custom Install/Remove for Docker ---
install_docker() {
  echo -e "${YELLOW}Installing Docker...${RESET}"
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"${UBUNTU_CODENAME:-$VERSION_CODENAME}\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  echo -e "${YELLOW}Testing Docker installation...${RESET}"
  sudo docker run hello-world || echo -e "${RED}Docker test failed. Please check installation.${RESET}"
  echo -e "${GREEN}Docker install steps completed.${RESET}"
}

remove_docker() {
  echo -e "${YELLOW}Removing Docker...${RESET}"
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
  sudo apt-get autoremove -y --purge
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd
  sudo rm -f /etc/apt/sources.list.d/docker.list
  echo -e "${GREEN}Docker removed successfully.${RESET}"
}

# --- Custom Install/Remove for Terraform ---
install_terraform() {
  echo -e "${YELLOW}Installing Terraform...${RESET}"
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y terraform
  echo -e "${GREEN}Terraform installed successfully.${RESET}"
}

remove_terraform() {
  echo -e "${YELLOW}Removing Terraform...${RESET}"
  sudo apt-get remove -y terraform
  sudo rm -f /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update
  echo -e "${GREEN}Terraform removed successfully.${RESET}"
}

install_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to install '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      if [[ "$package" == "nodejs" ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
      elif [[ "$package" == "jupyter" ]]; then
        sudo apt-get install -y python3-pip python3-venv
        pip3 install jupyter
      else
        sudo apt-get update -y
        sudo apt-get install -y "$package"
      fi
    elif command_exists yum; then
      sudo yum install -y "$package"
    elif command_exists dnf; then
      sudo dnf install -y "$package"
    elif command_exists pacman; then
      sudo pacman -S --noconfirm "$package"
    else
      echo -e "${RED}Error: Unsupported package manager. Please install '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      brew install "$package"
    else
      echo -e "${RED}Error: Homebrew not found. Please install '$package' manually.${RESET}"
      return 1
    fi
  else
    echo -e "${RED}Error: Unsupported OS. Please install '$package' manually.${RESET}"
    return 1
  fi
  if command_exists "$package" || [[ "$package" == "jupyter" && -x "$(command -v jupyter)" ]]; then
    echo -e "${GREEN}'$package' installed successfully.${RESET}"
    return 0
  else
    echo -e "${RED}Error installing '$package'. Please check the output.${RESET}"
    return 1
  fi
}

remove_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to remove '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      if [[ "$package" == "jupyter" ]]; then
        pip3 uninstall -y jupyter
      else
        sudo apt-get remove -y "$package"
      fi
    elif command_exists yum; then
      sudo yum remove -y "$package"
    elif command_exists dnf; then
      sudo dnf remove -y "$package"
    elif command_exists pacman; then
      sudo pacman -Rns --noconfirm "$package"
    else
      echo -e "${RED}Error: Unsupported package manager. Please remove '$package' manually.${RESET}"
      return 1
    fi
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    if command_exists brew; then
      brew uninstall "$package"
    else
      echo -e "${RED}Error: Homebrew not found. Please remove '$package' manually.${RESET}"
      return 1
    fi
  else
    echo -e "${RED}Error: Unsupported OS. Please remove '$package' manually.${RESET}"
    return 1
  fi
  echo -e "${GREEN}'$package' removed.${RESET}"
  return 0
}

purge_package() {
  local package="$1"
  if [[ "$(uname -s)" == "Linux" ]] && command_exists apt-get; then
    echo -e "${YELLOW}Attempting to purge '$package' (remove with config)...${RESET}"
    if [[ "$package" == "jupyter" ]]; then
      pip3 uninstall -y jupyter
      echo -e "${GREEN}'$package' purged (pip uninstall).${RESET}"
    else
      sudo apt-get purge -y "$package"
      echo -e "${GREEN}'$package' purged.${RESET}"
    fi
    return 0
  else
    echo -e "${YELLOW}Purge not supported or not Linux (apt-get). Using regular remove for '$package'.${RESET}"
    remove_package "$package"
    return 0
  fi
}

# --- Tool Management Function ---
manage_tool() {
  local tool="$1"
  local remove_only="$2" # Optional flag for tools where purge is risky

  echo "What do you want to do with '$tool'?"
  echo "  i) Install"
  echo "  r) Remove"
  if [[ -z "$remove_only" ]]; then
    echo "  p) Purge (Linux apt-get only)"
  fi
  echo "  c) Check if Installed"
  echo "  v) Check Version"
  echo "  u) Update (apt-get only)"
  echo "  q) Go back"
  read -p "Enter your choice: " action_choice

  case "$action_choice" in
    i)
      if [[ "$tool" == "docker" ]]; then
        install_docker
      elif [[ "$tool" == "terraform" ]]; then
        install_terraform
      else
        install_package "$tool"
      fi
      ;;
    r)
      if [[ "$tool" == "docker" ]]; then
        remove_docker
      elif [[ "$tool" == "terraform" ]]; then
        remove_terraform
      else
        remove_package "$tool"
      fi
      ;;
    p) if [[ -z "$remove_only" ]]; then purge_package "$tool"; else echo "Purge not available for this tool."; fi;;
    c)
      if command_exists "$tool"; then
        echo -e "${GREEN}$tool is installed.${RESET}"
      else
        echo -e "${RED}$tool is not installed.${RESET}"
      fi
      ;;
    v)
      version_package "$tool"
      ;;
    u)
      update_package "$tool"
      ;;
    q) return;;
    *) echo "Invalid action.";;
  esac
}

# --- Main Menu ---
while true; do
  print_header "Manage Optional Tools"
  echo "Choose a category:"
  echo "  1) Debugging Tools"
  echo "  2) Monitoring Tools"
  echo "  3) Network Tools"
  echo "  4) Text Utilities"
  echo "  5) Security Tools"
  echo "  6) Containerization Tools"
  echo "  7) Infrastructure as Code Tools"
  echo "  8) Cloud CLIs"
  echo "  9) Programming Tools"
  echo "  q) Quit"
  read -p "Enter your choice: " category_choice

  case "$category_choice" in
    1)
      print_header "Debugging Tools"
      echo "  a) htop (Install/Remove/Purge)"
      echo "  b) strace (Install/Remove/Purge)"
      echo "  c) tcpdump (Install/Remove/Purge)"
      echo "  d) wireshark (Install/Remove)"
      echo "  e) gdb (Install/Remove/Purge)"
      echo "  f) tmux (Install/Remove/Purge)"
      echo "  g) vim (Install/Remove/Purge)"
      echo "  h) neovim (Install/Remove/Purge)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "htop";;
        b) manage_tool "strace";;
        c) manage_tool "tcpdump";;
        d) manage_tool "wireshark" "remove";;
        e) manage_tool "gdb";;
        f) manage_tool "tmux";;
        g) manage_tool "vim";;
        h) manage_tool "neovim";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    2)
      print_header "Monitoring Tools"
      echo "  a) ncdu (Install/Remove/Purge)"
      echo "  b) iftop (Install/Remove/Purge)"
      echo "  c) bmon (Install/Remove/Purge)"
      echo "  d) nethogs (Install/Remove/Purge)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "ncdu";;
        b) manage_tool "iftop";;
        c) manage_tool "bmon";;
        d) manage_tool "nethogs";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    3)
      print_header "Network Tools"
      echo "  a) net-tools (Install/Remove/Purge)"
      echo "  b) dnsutils (Install/Remove/Purge)"
      echo "  c) nmap (Install/Remove/Purge)"
      echo "  d) netcat (Install/Remove/Purge)"
      echo "  e) traceroute (Install/Remove/Purge)"
      echo "  f) whois (Install/Remove/Purge)"
      echo "  g) sshuttle (Install/Remove/Purge)"
      echo "  h) sshpass (Install/Remove/Purge)"
      echo "  i) sshfs (Install/Remove/Purge)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "net-tools";;
        b) manage_tool "dnsutils";;
        c) manage_tool "nmap";;
        d) manage_tool "netcat";;
        e) manage_tool "traceroute";;
        f) manage_tool "whois";;
        g) manage_tool "sshuttle";;
        h) manage_tool "sshpass";;
        i) manage_tool "sshfs";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    4)
      print_header "Text Utilities"
      echo "  a) bat (Install/Remove/Purge)"
      echo "  b) lynx (Install/Remove/Purge)"
      echo "  c) jq (Install/Remove/Purge)"
      echo "  d) tree (Install/Remove/Purge)"
      echo "  e) ripgrep (Install/Remove/Purge)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "bat";;
        b) manage_tool "lynx";;
        c) manage_tool "jq";;
        d) manage_tool "tree";;
        e) manage_tool "ripgrep";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    5)
      print_header "Security Tools"
      echo "  a) burp-suite (Install/Remove)"
      echo "  b) sqlmap (Install/Remove)"
      echo "  c) msfconsole (Install/Remove)"
      echo "  d) feroxbuster (Install/Remove)"
      echo "  e) httprobe (Install/Remove)"
      echo "  f) subjack (Install/Remove)"
      echo "  g) gau (Install/Remove)"
      echo "  h) gobuster (Install/Remove)"
      echo "  i) whatweb (Install/Remove)"
      echo "  j) nikto (Install/Remove)"
      echo "  k) dirsearch (Install/Remove)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "burp-suite" "remove"; echo "Note: Burp Suite might require manual installation.";;
        b) manage_tool "sqlmap" "remove";;
        c) manage_tool "msfconsole" "remove";;
        d) manage_tool "feroxbuster" "remove";;
        e) manage_tool "httprobe" "remove";;
        f) manage_tool "subjack" "remove";;
        g) manage_tool "gau" "remove";;
        h) manage_tool "gobuster" "remove";;
        i) manage_tool "whatweb" "remove";;
        j) manage_tool "nikto" "remove";;
        k) manage_tool "dirsearch" "remove";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    6)
      print_header "Containerization Tools"
      echo "  a) docker (Install/Remove/Purge)"
      echo "  b) kubectl (Install/Remove)"
      echo "  c) helm (Install/Remove)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "docker";;
        b) manage_tool "kubectl" "remove"; echo "Note: Kubectl might require specific removal steps.";;
        c) manage_tool "helm" "remove"; echo "Note: Helm might require specific removal steps.";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    7)
      print_header "Infrastructure as Code Tools"
      echo "  a) terraform (Install/Remove)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "terraform" "remove";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    8)
      print_header "Cloud CLIs"
      echo "  a) awscli (Install/Remove)"
      echo "  b) gcloud (Install/Remove)"
      echo "  c) azurecli (Install/Remove)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "awscli" "remove"; echo "Note: AWS CLI might require pip uninstall.";;
        b) manage_tool "gcloud" "remove"; echo "Note: gcloud might have its own uninstaller.";;
        c) manage_tool "azurecli" "remove"; echo "Note: Azure CLI might require pip uninstall.";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    9)
      print_header "Programming Tools"
      echo "  a) nodejs (Install/Remove)"
      echo "  b) python3 (Install/Remove/Purge)"
      echo "  c) jupyter (Install/Remove/Purge)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "nodejs" "remove";;
        b) manage_tool "python3";;
        c) manage_tool "jupyter";;
        q) continue 2;;
        *) echo "Invalid option.";;
      esac
      ;;
    q)
      echo "Exiting tool management."
      break;;
    *)
      echo "Invalid choice.";;
  esac
done
echo -e "${GREEN}Exiting tool management.${RESET}"
# fi
# echo -e "${GREEN}Shell configuration completed successfully!${RESET}"
# echo -e "${YELLOW}Please restart your terminal or source your shell configuration file to apply changes.${RESET}"
# echo -e "${YELLOW}For Zsh users, run 'p10k configure' to set up your Powerlevel10k theme.${RESET}"
# echo -e "${YELLOW}For Bash users, run 'starship init bash' to set up your Starship theme.${RESET}"
# echo -e "${YELLOW}For Zsh users, run 'starship init zsh' to set up your Starship theme.${RESET}"
# echo -e "${YELLOW}For Zsh users, run 'zsh-autosuggestions' to set up your Zsh autosuggestions.${RESET}"
# echo -e "${YELLOW}For Zsh users, run 'zsh-syntax-highlighting' to set up your Zsh syntax highlighting.${RESET}"
# echo -e "${YELLOW}For Zsh users, run 'zsh-completions' to set up your Zsh completions.${RESET}"
# echo -e "${YELLOW}For Zsh users, run 'zsh-history-substring-search' to set up your Zsh history substring search.${RESET}"
