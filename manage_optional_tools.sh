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

command_exists () {
  command -v "$1" >/dev/null 2>&1
}

install_package() {
  local package="$1"
  echo -e "${YELLOW}Attempting to install '$package'...${RESET}"
  if [[ "$(uname -s)" == "Linux" ]]; then
    if command_exists apt-get; then
      sudo apt-get update -y
      sudo apt-get install -y "$package"
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
  if command_exists "$package"; then
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
      sudo apt-get remove -y "$package"
    elif command_exists yum; then
      sudo yum remove -y "$package"
    elif command_exists dnf; then
      sudo dnf remove -y "$package"
    elif command_exists pacman; then
      sudo pacman -Rns --noconfirm "$package" # Remove with dependencies and config
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
    sudo apt-get purge -y "$package"
    echo -e "${GREEN}'$package' purged.${RESET}"
    return 0
  else
    echo -e "${YELLOW}Purge not supported or not Linux (apt-get). Using regular remove for '$package'.${RESET}"
    remove_package "$package"
    return 0
  fi
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
  echo "  q) Quit"
  read -p "Enter your choice: " category_choice

  case "$category_choice" in
    1)
      print_header "Debugging Tools"
      echo "  a) htop (Install/Remove/Purge)"
      echo "  b) strace (Install/Remove/Purge)"
      echo "  c) tcpdump (Install/Remove/Purge)"
      echo "  d) wireshark (Install/Remove)" # Purge might remove essential GUI libs
      echo "  e) gdb (Install/Remove/Purge)"
      echo "  f) tmux (Install/Remove/Purge)"
      echo "  g) vim (Install/Remove/Purge)"
      echo "  h) neovim (Install/Remove/Purge)"
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "htop";;
        b) manage_tool "strace";;
        c) manage_tool "tcpdump";;
        d) manage_tool "wireshark" "remove";; # No purge
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
      echo "  a) burp-suite (Install/Remove)" # GUI - manual install likely
      echo "  b) sqlmap (Install/Remove)" # Python based
      echo "  c) msfconsole (Install/Remove)" # Metasploit
      echo "  d) feroxbuster (Install/Remove)" # Rust based
      echo "  e) httprobe (Install/Remove)" # Go based
      echo "  f) subjack (Install/Remove)" # Go based
      echo "  g) gau (Install/Remove)" # Go based
      echo "  h) gobuster (Install/Remove)" # Go based
      echo "  i) whatweb (Install/Remove)" # Ruby based
      echo "  j) nikto (Install/Remove)" # Perl based
      echo "  k) dirsearch (Install/Remove)" # Python based
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
      echo "  b) kubectl (Install/Remove)" # Often installed via specific method
      echo "  c) helm (Install/Remove)"   # Often installed via specific method
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
      echo "  a) awscli (Install/Remove)" # Often installed via pip
      echo "  b) gcloud (Install/Remove)" # Often has its own installer
      echo "  c) azurecli (Install/Remove)" # Often installed via pip
      read -p "Enter option (or q to go back): " tool_choice
      case "$tool_choice" in
        a) manage_tool "awscli" "remove"; echo "Note: AWS CLI might require pip uninstall.";;
        b) manage_tool "gcloud" "remove"; echo "Note: gcloud might have its own uninstaller.";;
        c) manage_tool "azurecli" "remove"; echo "Note: Azure CLI might require pip uninstall.";;
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
  echo "  q) Go back"
  read -p "Enter your choice: " action_choice

  case "$action_choice" in
    i) install_package "$tool";;
    r) remove_package "$tool";;
    p) if [[ -z "$remove_only" ]]; then purge_package "$tool"; else echo "Purge not available for this tool."; fi;;
    q) return;;
    *) echo "Invalid action.";;
  esac
}
