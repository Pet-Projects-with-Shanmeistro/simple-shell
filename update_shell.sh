#!/bin/bash

# Check if Ansible is installed
if ! command -v ansible &> /dev/null
then
    echo "Ansible not found, installing..."
    bash install_ansible.sh
else
    echo "Ansible is already installed."
fi

# Run the Ansible playbook
ansible-playbook playbooks/setup.yml --extra-vars "update_zsh_from_repo=true"
