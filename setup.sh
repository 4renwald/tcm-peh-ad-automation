#!/bin/bash

# Error handling for the script
set -e
trap 'error_handling' EXIT

error_handling() {
    exit_status=$?
    if [ "$exit_status" -ne 0 ]; then
        print_error "There was an error while executing the script (Exit Status: $exit_status)"
    fi
}

# Functions for output format
function print_success () {
    echo -e "\x1B[01;32m[+] $1\x1B[0m"
}

function print_error () {
    echo -e "\x1B[01;31m[!] $1\x1B[0m"
}

function print_warning () {
    echo -e "\x1B[01;33m[-] $1\x1B[0m"
}

function print_info () {
    echo -e "\x1B[01;34m[*] $1\x1B[0m"
}

# Source the IP address configuration file
source ./ip_addresses.sh

# Shared workstations variables
workstations_local_administrator_password='Password1!'

# Variables for the domain controller. 
HYDRA_DC_HOSTNAME='HYDRA-DC'
HYDRA_DC_local_admin_username='administrator'
HYDRA_DC_local_admin_password='P@$$w0rd!'
DOMAIN_NAME='MARVEL.local'

# Variables for THEPUNISHER
THEPUNISHER_HOSTNAME='THEPUNISHER'
THEPUNISHER_local_admin_username='frankcastle'
THEPUNISHER_local_admin_password='Password1'


# Variables for SPIDERMAN
SPIDERMAN_HOSTNAME='SPIDERMAN'
SPIDERMAN_local_admin_username='peterparker'
SPIDERMAN_local_admin_password='Password1'

# Install dependencies
function dependencies () {
    print_info "Installing required dependencies"

    if [ -d ".venv" ]; then
        print_warning "Virtual environment '.venv' already exists and will be used"
    else
        print_info "Creating virtualenv for ansible"
        python3 -m venv ".venv"
        print_success "Python virtualenv created"
        echo
    fi
    
    print_info "Installing packages inside virtualenv"
    source "./.venv/bin/activate"
    packages=("ansible" "pypsrp[credssp]<=1.0.0")

    for pkg in "${packages[@]}"; do
        pkg_name=$(echo "$pkg" | sed 's/[<>=].*//')
        if ! pip show "$pkg_name" > /dev/null 2>&1; then
            print_info "Installing $pkg"
            pip install --no-cache-dir "$pkg" -q -q -q
        else
            print_info "$pkg is already installed"
        fi
    done

    print_success "Dependencies installed"
    echo
}

# Configure ansible extra_vars used across all playbooks
function setting_extra_vars () {
    print_info "Setting global ansible extra_vars"
    extra_vars+="target_domain_controller=${HYDRA_DC_HOSTNAME} "
    extra_vars+="target_domain_name=${DOMAIN_NAME} "
    extra_vars+="domain_admin_username=${HYDRA_DC_local_admin_username}@${DOMAIN_NAME} "
    extra_vars+="domain_admin_password=${HYDRA_DC_local_admin_password} "
    extra_vars+="domain_dns_ip=${HYDRA_DC_IP} "
    extra_vars+="local_administrator_password=${workstations_local_administrator_password} "
    print_success "Ansible extra_vars configured"
    echo
}

# Setup HYDRA-DC
function HYDRA-DC_setup () { 
    source "./.venv/bin/activate"
    print_info "HYDRA-DC: Starting ansible extra_vars configuration"
    extra_vars+="hostname=${HYDRA_DC_HOSTNAME} "
    extra_vars+="ansible_host=${HYDRA_DC_IP} "
    extra_vars+="ansible_user=${HYDRA_DC_local_admin_username} "
    extra_vars+="ansible_password=${HYDRA_DC_local_admin_password} "
    print_success "HYDRA_DC: Ansible extra_vars configured"
    print_info "HYDRA-DC: Starting ansible tasks"
    ansible-playbook ansible/HYDRA-DC.yml -i ansible/inventory/inventory.yml --extra-vars "${extra_vars}"
    print_success "HYDRA-DC: Setup completed"
    echo
}

# Setup THEPUNISHER
function THEPUNISER_setup () {
    source "./.venv/bin/activate"
    print_info "THEPUNISHER: Starting ansible extra_vars configuration"
    extra_vars+="hostname=${THEPUNISHER_HOSTNAME} "
    extra_vars+="ansible_host=${THEPUNISHER_IP} "
    extra_vars+="ansible_user=${THEPUNISHER_local_admin_username} "
    extra_vars+="ansible_password=${THEPUNISHER_local_admin_password} "
    print_success "THEPUNISHER: Ansible extra_vars configured"
    print_info "THEPUNISHER: Starting ansible tasks"
    ansible-playbook ansible/THEPUNISHER.yml -i ansible/inventory/inventory.yml --extra-vars "${extra_vars}"
    print_success "THEPUNISHER: Setup completed"
    echo
}

# Setup SPIDERMAN
function SPIDERMAN_setup () {
    source "./.venv/bin/activate"
    print_info "SPIDERMAN: Starting ansible extra_vars configuration"
    extra_vars+="hostname=${SPIDERMAN_HOSTNAME} "
    extra_vars+="ansible_host=${SPIDERMAN_IP} "
    extra_vars+="ansible_user=${SPIDERMAN_local_admin_username} "
    extra_vars+="ansible_password=${SPIDERMAN_local_admin_password} "
    print_success "SPIDERMAN: Ansible extra_vars configured"
    print_info "SPIDERMAN: Starting ansible tasks"
    ansible-playbook ansible/SPIDERMAN.yml -i ansible/inventory/inventory.yml --extra-vars "${extra_vars}"
    print_success "SPIDERMAN: Setup completed"
    echo
}

function main () {
    dependencies
    setting_extra_vars
    HYDRA-DC_setup
    THEPUNISER_setup
    SPIDERMAN_setup
    print_success "Lab configured successfully!"
}

main