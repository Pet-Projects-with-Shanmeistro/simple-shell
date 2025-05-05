# ✨ My Awesome Development Environment Setup ✨

Welcome to **My Awesome Dev Environment Setup!** This repository provides a fully automated and customizable way to create a consistent, efficient, and personalized development environment on your local machine. Say goodbye to tedious manual configuration and hello to a ready-to-code setup in minutes!

---

## 📖 Table of Contents

- [🚀 Benefits of Using This Setup](#-benefits-of-using-this-setup)
- [🛠️ Prerequisites](#️-prerequisites)
- [⚙️ Installation](#️-installation)
- [💻 Usage](#-usage)
- [🛠️ Managing Optional Tools](#️-managing-optional-tools)
- [⚙️ Running the Playbook Directly (Advanced)](#️-running-the-playbook-directly-advanced)
- [📂 Roles Overview](#-roles-overview)
- [⚙️ Customization](#️-customization)
- [🤝 Contributing](#-contributing)

---

## 🚀 Benefits of Using This Setup

- **Consistency:** Ensure a uniform development environment across different machines.
- **Time-Saving:** Automate the installation of essential tools and configurations, saving you valuable setup time.
- **Easy Customization:** Choose your preferred shell and prompt framework during installation.
- **Modularity:** The setup is organized into logical roles, making it easy to understand and extend.
- **Flexibility:** Supports both Bash and Zsh shells with options for popular prompt frameworks like Starship and Powerlevel10k.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed on your system:

- **Ansible:** Version 2.9 or higher (used for the automation).
- **Git:** For cloning this repository.
- **Curl:** For downloading necessary scripts and files.
- **sudo Privileges:** Administrative rights are required for installing packages.

---

## ⚙️ Installation

Follow these simple steps to set up your awesome development environment:

### 1. Clone the Repository

```bash
git clone <repository_url>
cd my-awesome-shell-setup
```

(Replace <repository_url> with the actual URL of your repository.)

### 2. Make the Installation Script Executable

```bash
chmod +x install_custom_shell.sh
```

### 3. Run the Installation Script

```bash
./install_custom_shell.sh
```

This script will:

- Check for the necessary prerequisites.
- Prompt you to choose your preferred shell (Bash or Zsh).
- If you choose Zsh, it will ask for your preferred prompt framework (Starship or Powerlevel10k).
- Ask if you want to set Zsh as your default shell (if chosen).
- Run the Ansible playbook to configure your environment with essential tools.

### 4. Apply Changes

After the script completes, restart your terminal or run:

- `source ~/.bashrc` (for Bash)
- `exec zsh` (for Zsh)

---

## 💻 Usage

Once the installation is complete, you'll have a personalized development environment ready to go! Here are some tips:

- **Explore Your New Shell:** Enjoy the enhanced features and prompt of your chosen shell (Bash with Starship or Zsh with Starship/Powerlevel10k).
- **Customize Further:**
  - **Starship:** Configure your Starship prompt by editing the `~/.config/starship.toml` file.
  - **Powerlevel10k:** If you chose Zsh with Powerlevel10k, you can further customize it by running p10k configure in your terminal.
- **Utilize Installed Tools:** The sysadmin-tools and dev-tools roles install a variety of useful utilities that are now at your fingertips.

---

## 🛠️ Managing Optional Tools

A separate script, `manage_optional_tools.sh`, is provided to install, remove, and even purge (where supported) additional tools that are not part of the default setup. Run the script and follow the interactive menu.

```bash
./manage_optional_tools.sh
```

This script offers granular control over tools like debugging utilities, monitoring tools, network tools, and more, without needing to directly edit Ansible configuration files for these optional packages.

---

## ⚙️ Running the Playbook Directly (Advanced)

For more fine-grained control, you can run the Ansible playbook directly:

```bash
ansible-playbook -i ansible/inventory/localhost ansible/custom_dev_env.yml -K --tags <role_tag>
```

- -K: Prompts for the sudo password.
- --tags <role_tag>: Allows you to run specific roles (e.g., common, shell, sysadmin-tools, dev-tools).

---

## 📂 Roles Overview

This setup is organized into the following Ansible roles:

- `common`: Contains tasks that are common to all environments, such as basic system configurations.
- `shell`: Configures your chosen shell (Bash or Zsh) and sets up the prompt.
- `sysadmin-tools`: Installs essential system administration and networking utilities (e.g., htop, tmux, nmap, iproute2).
- `dev-tools`: Installs development-related tools, including Python, uv, ruff, taplo, Node.js (nvm), and more.

---

## ⚠️ Removing Packages and Libraries

This script primarily installs tools using your system's package manager or via tools like pip. To completely remove a tool and its dependencies, you should use the appropriate uninstallation command for the package manager that installed it (e.g., `sudo apt remove <package>`, `brew uninstall <package>`, `pip uninstall <package>)`. The `manage_optional_tools.sh` script provides an interface for removing some of these tools. Manual removal is recommended to avoid unintended consequences.

---

## ⚙️ Customization

Beyond the initial setup and optional tools management, you can further customize your environment by:

- **Modifying Role Tasks:** Edit the task files within the `ansible/roles/` directories to change installation procedures or add new tools.
- **Creating New Roles:** Organize more complex customizations into new roles and include them in the `ansible/custom_dev_env.yml` playbook.

---

## 🤝 Contributing

Contributions to this project are welcome! Feel free to submit pull requests with improvements, bug fixes, or new features. Please follow standard Git contribution guidelines.

---

2025 Shannon
