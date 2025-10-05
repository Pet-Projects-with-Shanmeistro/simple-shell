# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/) (optional, but good to know).

## [0.2.0] - 2025-10-05

### Added

- **Comprehensive Nerd Fonts Management System**:
  - New standalone `manage_fonts.sh` script with full cross-platform support (Linux, macOS, Windows, WSL)
  - Interactive and command-line interfaces for font installation/uninstallation
  - Support for multiple font selection and bulk operations
  - Automatic font cache refresh and backup functionality
  - WSL integration for dual Linux/Windows font installation
  - Ansible integration with proper JSON output mode

- **Enhanced Font Collection**:
  - Added JetBrains Mono, Hack, Source Code Pro, Ubuntu Mono, DejaVu Sans Mono, and Inconsolata Nerd Fonts
  - Organized font variants (Regular, Mono, Proportional) with clear labeling
  - Font recommendations optimized for Powerlevel10k and Starship configurations

- **Improved Shell Installation Experience**:
  - Enhanced font installation option as second menu item in main installer
  - Better font family selection with descriptions and installation status
  - Post-installation guidance with terminal configuration instructions
  - Cross-platform font directory detection and management

- **Advanced Font Management Features**:
  - Font backup system with timestamp-based versioning
  - Safe uninstallation with confirmation prompts
  - Font status reporting and system information display
  - Comprehensive logging for troubleshooting

### Changed

- **Enhanced `install_custom_shell.sh`**:
  - Restructured main menu to prominently feature font installation
  - Improved font selection UI with better status indicators
  - Added support for multiple font installation modes
  - Better error handling and user feedback

- **Ansible Integration**:
  - Added dedicated font management role with configurable font lists
  - Support for selective font installation via group variables
  - Proper task tagging for font-specific operations

### Technical Improvements

- Cross-platform font directory management
- Improved detection of WSL environments
- Better font cache management across different operating systems
- Enhanced logging and debugging capabilities
- Modular design allowing standalone or integrated usage

## [0.1.1] - 2025-07-28

### Added

- Enhanced `manage_optional_tools.sh` with:
  - Custom Docker and Terraform install/uninstall functions using official repository steps.
  - Options to check if a tool is installed, check its version, and update it (apt-get only).
  - Improved menu-driven interface for tool management.
- Added helper functions for version and update checks.
- Provided guidance and review for `.tmux.conf` to help new users, including color scheme troubleshooting and minimal config recommendations.

### Changed

- Refactored `manage_optional_tools.sh` to integrate advanced tool management and user feedback.
- Updated `.tmux.conf` recommendations for better usability and default color scheme restoration.

### Fixed

- Addressed issues with overly bright tmux color schemes by clarifying which config lines to comment/remove for defaults.

## [0.1.0] - 2025-05-05

### Added

- Initial Ansible setup with roles for common utilities, shell configuration, sysadmin tools, and dev tools.
- Interactive `install_custom_shell.sh` script for initial setup and shell/prompt selection.
- `manage_optional_tools.sh` script for managing additional tools.
- Basic `tmux` configuration (see `tmux.conf`).
- Support for Bash and Zsh shells.
- Support for Starship and Powerlevel10k prompt frameworks.
- Installation of essential DevOps, Full Stack, and AI/ML development tools.
- Tagging added to Ansible roles for selective execution.

### Removed

- Removed Jinja2 templates for initial simplicity. These may be reintroduced later.
- Removed the `manage_packages.py` script.
- Removed the `dotfiles` folder (except for the `tmux.conf`).

### Changed

- Simplified the `group_vars/all.yml` to focus on core configurations.
- Streamlined the Ansible roles for clarity and error handling.
- Updated `README.md` to reflect the current setup.

---

## [0.1.0] - 2025-05-01 (Repo restructured)

### Added

- Initial setup with shell configuration (Bash/Zsh).
- Basic installation of common tools.
- Support for Starship and Powerlevel10k prompts.
- `install_custom_shell.sh` script for easy setup.

---

## [Unreleased] - YYYY-MM-DD

### Added

- New feature or tool.

### Changed

- Existing functionality or configuration.

### Fixed

- Bug fixes or issues.

### Removed

- Deprecated or removed features.

---
