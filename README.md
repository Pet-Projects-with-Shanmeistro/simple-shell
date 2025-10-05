# ✨ My Awesome Development Environment Setup ✨

Welcome to **My Awesome Dev Environment Setup!** This repository provides a fully automated and customizable way to create a consistent, efficient, and personalized development environment on your local machine. Say goodbye to tedious manual configuration and hello to a ready-to-code setup in minutes!

---

## 📖 Table of Contents

- [🚀 Benefits of Using This Setup](#-benefits-of-using-this-setup)
- [🛠️ Prerequisites](#️-prerequisites)
- [⚙️ Installation](#️-installation)
- [🎨 Nerd Fonts Management](#-nerd-fonts-management)
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
- **Beautiful Typography:** Comprehensive Nerd Fonts collection optimized for coding and terminal use.
- **Cross-Platform:** Full support for Linux, macOS, Windows, and WSL environments.
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
cd simple-shell
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

## 🎨 Nerd Fonts Management

This setup includes a comprehensive collection of Nerd Fonts, which are patched fonts that include additional glyphs and symbols for better coding and terminal use. The fonts are installed and managed automatically as part of the setup.

To change your terminal font to a Nerd Font:

1. Open your terminal preferences.
2. Look for the font or appearance settings.
3. Select a Nerd Font from the list of installed fonts (e.g., "Fira Code Nerd Font", "Hack Nerd Font", etc.).
4. Adjust the font size and other settings as desired.

For a complete list of available Nerd Fonts, check the `nerd-fonts` role in the Ansible configuration.

---

## 💻 Usage

Once the installation is complete, you'll have a personalized development environment ready to go! Here are some tips:

- **Explore Your New Shell:** Enjoy the enhanced features and prompt of your chosen shell (Bash with Starship or Zsh with Starship/Powerlevel10k).

- **Set Your Terminal Font:** Configure your terminal to use one of the installed Nerd Fonts:

  - VS Code: File → Preferences → Settings → Terminal Font Family
  - Terminal.app: Preferences → Profiles → Font
  - iTerm2: Preferences → Profiles → Text → Font
  - Windows Terminal: Settings → Profiles → Appearance → Font Face
  - GNOME Terminal: Preferences → Profiles → Text → Custom Font

**Customize Further:**

- **Starship:** Configure your Starship prompt by editing the `~/.config/starship.toml` file. Check the starship directory for preset configurations.
- **Powerlevel10k:** If you chose Zsh with Powerlevel10k, you can further customize it by running `p10k configure` in your terminal or use one of the presets in the p10k directory.
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

Available Tags
- common: Basic system configurations
- shell: Shell and prompt setup
- sysadmin-tools: System administration utilities
- dev-tools: Development tools and environments
- fonts: Nerd Fonts installation and management

---

## 📂 Roles Overview

This setup is organized into the following Ansible roles:

- `common`: Contains tasks that are common to all environments, such as basic system configurations.
- `shell`: Configures your chosen shell (Bash or Zsh) and sets up the prompt.
- `sysadmin-tools`: Installs essential system administration and networking utilities (e.g., htop, tmux, nmap, iproute2).
- `dev-tools`: Installs development-related tools, including Python, uv, ruff, taplo, Node.js (nvm), and more.
- `fonts`: Manages Nerd Fonts installation with configurable font lists and cross-platform support.

Font Configuration

You can customize which fonts to install by editing `all.yml`:

```bash
# Nerd Fonts Configuration
nerd_fonts_to_install:
  - CascadiaCode
  - FiraCode
  - JetBrainsMono
  # Add or remove fonts as needed

# Set to true to install all available fonts
install_all_fonts: false
```

---

## ⚠️ Removing Packages and Libraries

This script primarily installs tools using your system's package manager or via tools like pip. To completely remove a tool and its dependencies, you should use the appropriate uninstallation command for the package manager that installed it (e.g., `sudo apt remove <package>`, `brew uninstall <package>`, `pip uninstall <package>)`. The `manage_optional_tools.sh` script provides an interface for removing some of these tools. Manual removal is recommended to avoid unintended consequences.

For fonts, use the dedicated font manager:

```bash
./manage_fonts.sh
```
This script allows you to add or remove font families as needed. Manual removal is recommended to avoid unintended consequences.

The `manage_optional_tools.sh` script provides an interface for removing some of these tools. Manual removal is recommended to avoid unintended consequences.

---

## ⚙️ Customization

Beyond the initial setup and optional tools management, you can further customize your environment by:

**Font Management:** Use the `manage_fonts.sh` script to add or remove font families as needed.
**Prompt Presets:** Explore the starship and p10k directories for ready-to-use prompt configurations.
**Modifying Role Tasks:** Edit the task files within the roles directories to change installation procedures or add new tools.
**Creating New Roles:** Organize more complex customizations into new roles and include them in the `custom_dev_env.yml` playbook.
**Adding Fonts:** Download additional Nerd Fonts from the official repository and add them to the nerd_fonts directory.


---

## 🔧 Troubleshooting

### Font Issues
- Fonts not appearing: Restart your terminal application and refresh the font list
- Symbols not displaying: Ensure you're using a "Nerd Font" variant (not the original font)
- WSL font problems: Run the font manager as administrator for system-wide Windows installation

### General Issues
- Permission errors: Ensure you have sudo privileges and run scripts with appropriate permissions
- Missing dependencies: Check that all prerequisites are installed before running the setup
- Path issues: Make sure scripts are executable (chmod +x script_name.sh)

### Getting Help
- Check the log file at /tmp/nerd-fonts-manager.log for font installation issues
- Use `./manage_fonts.sh status` to check system information
- Run `fc-list | grep -i nerd` to verify font installation on Linux

---

## 🤝 Contributing
Contributions to this project are welcome! Feel free to submit pull requests with improvements, bug fixes, or new features. Please follow standard Git contribution guidelines.

Areas for Contribution
- Additional font families
- New prompt presets for Starship/Powerlevel10k
- Platform-specific optimizations
- Additional development tools
- Documentation improvements

---

Created with ❤️ by Shanmeistro - 2025

Making beautiful, functional development environments accessible to everyone!

