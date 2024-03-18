#!/usr/bin/env bash

# == WIP ==

# # check ubuntu distro
# checks(){
#     # distro = ubuntu
#     # ip = 192.168.1.40
#     # máquina => 201
# }

# OJO dotfiles/docs/linux/pi

setup_server_NFS(){
    sudo apt-get update && sudo apt-get install -y \
        nfs-kernel-server

    if [[ $? != 0 ]]; then
        echo 'Could not install NFS' && return 1
    fi

    if [[ ! -d /var/datos && $(! grep -q '/var/datos' /etc/exports; echo $?) ]]; then
        sudo mkdir -p /var/datos
        sudo chmod o+rwx /var/datos
        echo '/var/datos *(rw,sync,no_root_squash,no_all_squash)' | sudo tee -a /etc/exports
        sudo systemctl restart nfs-kernel-server
    else
        echo 'Existing NFS config detected. Not applying changes'
    fi

    # if showmount -e | grep -q '/var/datos *'; then
    #    echo ok
    # else
    #    echo dawg
    # fi

}

setup_client_NFS(){

    distro=$(grep -s "^ID=" /etc/os-release | awk -F '=' '{print $2}')
    case $distro in
        'ubuntu') sudo apt-get update && sudo apt-get install -y nfs-common ;;
        'fedora') sudo dnf in -y nfs-utils ;;
        'arch') sudo pacman -Sy --noconfirm nfs-utils ;;
        *) : ;;
    esac

    if [[ ! -d /var/datos ]]; then
        sudo mkdir /var/datos
        sudo mount -t nfs ns.cluster.net:/var/datos /var/datos
    else
        sudo mount -t nfs ns.cluster.net:/var/datos /var/datos
    fi

    #showmount -e <server_IP>
}


# ==========


# if hostname -I | grep -q 201; then
#     setup_NFS_server
# else
#     setup_NFS_clients
# fi
