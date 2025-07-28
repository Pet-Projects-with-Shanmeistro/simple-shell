# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/) (optional, but good to know).


## [0.2.0] - 2025-07-28

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
