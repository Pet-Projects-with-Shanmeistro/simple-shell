# My Awesome Shell Setup 🚀

This repository automates the setup of a custom shell and IDE environment for Linux and WSL2 systems using Ansible. It is designed to streamline the installation and configuration of essential tools, settings, and profiles, ensuring a consistent and efficient development workflow.

## Features

### VS Code Setup

- Installs VS Code.
- Configures VS Code with custom profiles and settings.
- Installs extensions from a pre-defined list.

### Shell Customization

- Installs Zsh and Oh-My-Zsh.
- Configures Powerlevel10K theme with custom .zshrc and .p10k.zsh files.
- Supports skipping or updating existing configurations.

### Nerd Fonts

- Installs FiraCode Nerd Font for Powerline support.

### Development Tools

- Installs Docker, Kubernetes, and Terraform.
- Ensures proper handling for WSL2 environments.

### Cloud CLI Tools

- Installs the CLI tools for AWS and Azure.

### Python Environment

- Ensures Python 3, pip3, and penv are installed and up-to-date.

## Prerequisites

- Supported Operating Systems:
  - Ubuntu 22.04 (native Linux or WSL2).
- Git Installed:
  - Clone this repository to your local machine.
- Python 3 (required for Ansible):

  ```bash
  sudo apt update && sudo apt install -y python3 python3-pip
  ```bash

## Setup Instructions

### 1. Clone the Repository

Clone the repository into your desired directory:

```bash
git clone https://github.com/<your-username>/my_awesome_shell_setup.git
cd my_awesome_shell_setup
```bash

### 2. Run the Setup Script

The main setup script will check for Ansible and initiate the playbook.

### Default Setup

To perform the standard setup without overwriting existing configurations:

```bash
bash install_ansible.sh
```bash

### Update Configuration Files

If you want to overwrite existing configurations (e.g., `.zshrc`, `.p10k.zsh`), use the `--extra-vars` flag:

```bash
bash install_ansible.sh --extra-vars "update_configs=true update_zsh_from_repo=true"
```bash

## Customizing the Setup

### Configuration Files

- Custom Zsh Configuration:
  - `.zshrc`: Located in `roles/zsh/files/.zshrc`.
  - `.p10k.zsh`: Located in `roles/zsh/files/.p10k.zsh`.

- VS Code Settings:
  - `settings.json`: Located in `roles/vscode/files/settings.json`.
  - Extensions list: `roles/vscode/files/vscode-extensions.txt`.
  - Profiles: `roles/vscode/files/Shanmeistro.code-profile`.

### Update Extensions

To update the list of VS Code extensions:

```bash
code --list-extensions > roles/vscode/files/vscode-extensions.txt
```bash

## How It Works

### 1. Bash Script

- Installs Ansible if not found.
- Runs the main playbook with optional flags for configuration updates.

### 2. Ansible Playbook

- Modularized roles for installing and configuring tools and environments.
- Detects whether running in WSL2 and adapts behavior (e.g., skips Docker installation).

## Key Features

### Modular Roles

Each component is handled by an individual Ansible role, making it easy to add, remove, or customize:

- zsh: Installs and configures Zsh with Oh-My-Zsh and Powerlevel10K.
- vscode: Sets up VS Code with custom profiles and extensions.
- cloud-cli: Installs CLI tools for Azure and AWS.
- devtools: Installs Docker, Kubernetes, and Terraform, while handling WSL2 specifics.
- python: Ensures Python 3 and pip are installed, along with `penv`.
- nerd-fonts: Installs FiraCode Nerd Font.

## WSL2 and Native Linux

This setup automatically detects if it’s running in WSL2:

- Skips Docker and Kubernetes installation if Docker Desktop with Kubernetes is already available.
- Adjusts configurations as needed for compatibility.

## Example Usage with shell script

### 1. Standard Install Without Config Updates
```bash
./install_ansible.sh
```bash

### 2. Update Only Zsh from Repo
```bash
./install_ansible.sh --extra-vars "update_zsh_from_repo=true"
```bash

### 3. Update Everything (User Gets a Confirmation)
```bash
./install_ansible.sh --extra-vars "update_zsh_from_repo=true update_configs=true"
```bash

### 4. Test Playbook Without Making Changes
```bash
./install_ansible.sh --dry-run --extra-vars "update_zsh_from_repo=true"
```bash

## Troubleshooting

### 1. Permission Issues

- If you encounter permission issues, ensure your user has sudo access and re-run the script.

### 2. Skipping Tasks

- Tasks are skipped if the target state is already achieved (e.g., apps installed, files present).
- Use `--extra-vars "update_configs=true"` to force updates.

### 3. Ansible Errors

- Ensure you’re using Python 3:

```bash
   sudo apt install -y python3 python3-pip
```bash

### 4. WSL-Specific Issues

- Verify WSL2 is enabled with:

```bash
   wsl --list --verbose
```bash

## Contributing

Contributions are welcome! If you’d like to suggest changes or report bugs:

### 1. Fork this repository

### 2. Create a feature branch

```bash
git checkout -b feature/new-feature
```bash

### 3. Commit your changes and open a pull request
