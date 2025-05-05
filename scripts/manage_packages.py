#!/usr/bin/env python3

import yaml
import subprocess

def get_installed_packages():
    """Returns a set of currently installed package names."""
    try:
        result = subprocess.run(['dpkg', '-l'], capture_output=True, text=True, check=True)
        installed = set()
        for line in result.stdout.splitlines():
            if line.startswith('ii'):
                parts = line.split()
                if len(parts) > 1:
                    installed.add(parts[1])
        return installed
    except subprocess.CalledProcessError as e:
        print(f"Error listing installed packages: {e}")
        return set()

def load_packages_to_manage(yaml_file):
    """Loads package lists for management from the YAML file."""
    try:
        with open(yaml_file, 'r') as f:
            data = yaml.safe_load(f)
            install_packages = data.get('packages_to_manage', {}).get('install', [])
            remove_packages = data.get('packages_to_manage', {}).get('remove', [])
            return install_packages, remove_packages
    except FileNotFoundError:
        print(f"Error: YAML file '{yaml_file}' not found.")
        return [], []
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}")
        return [], []

def install_package(package_name):
    """Installs a given package using apt."""
    try:
        print(f"Installing {package_name}...")
        subprocess.run(['sudo', 'apt', 'install', '-y', package_name], check=True)
        print(f"Successfully installed {package_name}.")
    except subprocess.CalledProcessError as e:
        print(f"Error installing {package_name}: {e}")

def remove_and_purge_package(package_name):
    """Removes and purges a given package using apt."""
    try:
        print(f"Removing and purging {package_name}...")
        subprocess.run(['sudo', 'apt', 'purge', '-y', package_name], check=True)
        print(f"Successfully removed and purged {package_name}.")
    except subprocess.CalledProcessError as e:
        print(f"Error removing and purging {package_name}: {e}")

if __name__ == "__main__":
    yaml_file = 'package_management.yml'  # Changed to the new YAML file
    install_list, remove_list = load_packages_to_manage(yaml_file)
    installed = get_installed_packages()

    print("\n--- Packages to Install ---")
    for package in install_list:
        if package not in installed:
            answer = input(f"Do you want to install package '{package}'? (y/N): ").lower()
            if answer == 'y':
                install_package(package)
        else:
            print(f"Package '{package}' is already installed.")

    print("\n--- Packages to Remove and Purge ---")
    for package in remove_list:
        if package in installed:
            answer = input(f"Do you want to remove and purge package '{package}'? (y/N): ").lower()
            if answer == 'y':
                remove_and_purge_package(package)
        else:
            print(f"Package '{package}' is not currently installed.")

    print("\n--- Task Complete ---")