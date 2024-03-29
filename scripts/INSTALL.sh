#!/usr/bin/env bash

# ##################################################
# Must be updated upon software releases
# Kubeadm pod-network defined as 10.0.0.0/16
# Assuming LAN is 192.168.1.0/24
# Testing NAT 192.168.10.0/24
# $ bash -c "$(curl -fsSL https://raw.githubusercontent.com/pabloqpacin/k8s-bs/main/scripts/INSTALL.sh)"
# ##################################################

RESET='\e[0m'
GREEN='\e[32m'
YELLOW='\e[33m'

check_distro(){
    distro=$(grep -s "^ID=" /etc/os-release | awk -F '=' '{print $2}')
    case $distro in
        'ubuntu'|'fedora'|'arch') ;;
        *)
            echo -e "\n== ${YELLOW}Distro '$distro' not supported, terminating script${RESET} =="
            exit 1
        ;;
    esac
}

initial_setup(){
    # Just guidance. Don't automate that initial_setup from this actual script aight
    return 1

    case $distro in
        'ubuntu') bash -c "$(curl -fsSL https://raw.githubusercontent.com/pabloqpacin/dotfiles/main/scripts/autosetup/UbuntuServer-base.sh)" ;;
        'fedora') bash -c "$(curl -fsSL https://raw.githubusercontent.com/pabloqpacin/dotfiles/main/scripts/autosetup/FedoraServer-base.sh)" ;;
        'arch') xdg-open "https://github.com/pabloqpacin/dotfiles/blob/main/docs/linux/Arch_Hypr.md" ;;
        *) : ;;
    esac
}

install_docker(){
    if docker &>/dev/null; then
        echo -e "\n== ${YELLOW}Docker already installed on '$distro'${RESET} =="
        docker --version
        return 1
    else
        echo -e "\n== ${YELLOW}Installing Docker on '$distro'${RESET} =="
    fi

    case $distro in
        'ubuntu'|'debian'|'pop')
            # Add Docker's official GPG key:
            sudo apt-get update
            sudo apt-get install ca-certificates curl
            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/$distro/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc
            # Add the repository to Apt sources:
            echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$distro \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update

            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl enable --now docker
            sudo usermod -aG docker $USER
        ;;

        'fedora')
            # Install the dnf-plugins-core package (which provides the commands to manage your DNF repositories) and set up the repository.
            sudo dnf -y install dnf-plugins-core
            sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

            yes | sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            sudo systemctl enable --now docker
            sudo usermod -aG docker $USER
        ;;

        'arch')
            sudo pacman -Sy --noconfirm docker docker-buildx docker-compose
        ;;

        *) ;;
    esac
}

check_ports(){
    # WIP
    return 1

    ports=('6643' '2379' '2380' '10250' '10259' '10257' '30000' '32767')
    for i in "${!ports[@]}"; do
        ncat localhost "${ports[i]}" -v || nc localhost "${ports[i]}" -v
        if [ $? != 1 ]; then
            echo "Ports busy. Not installing kubernetes"
            exit 1
        fi
    done
}

disable_swap(){
    if ! grep -q -e 'swap' -e 'dev' /proc/swaps; then
        return 1
    else
        echo -e "\n== ${YELLOW}Disabling SWAP on '$distro'${RESET} =="
    fi

    case $distro in
        'ubuntu')
            sudo sed -i '/swap/s/^/# /' /etc/fstab &&
            sudo swapoff --all
        ;;
        'fedora')
            sudo dnf remove -y zram-generator-defaults &&
            sudo swapoff --all

            # OJO
            sudo systemctl disable --now firewalld
        ;;
    esac
}

install_kubernetes(){
    if kubectl &>/dev/null; then
        echo -e "\n== ${YELLOW}Kubernetes already installed on '$distro'${RESET} =="
        kubectl version
        return 1
    else
        echo -e "\n== ${YELLOW}Installing Kubernetes on '$distro'${RESET} =="
    fi

    case $distro in
        'ubuntu'|'debian'|'pop')
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl gpg
            # Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:
            if [ ! -d '/etc/apt/keyrings' ]; then sudo mkdir -p -m 755 /etc/apt/keyrings; fi
            curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
            # Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.29
            echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
            # Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
            sudo apt-get update
            sudo apt-get install -y kubelet kubeadm kubectl
            sudo apt-mark hold kubelet kubeadm kubectl
            sudo systemctl enable --now kubelet
        ;;

        'fedora')
            # Set SELinux in permissive mode (effectively disabling it)
            sudo setenforce 0
            sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
            # This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
            {
                echo '[kubernetes]'
                echo 'name=Kubernetes'
                echo 'baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/'
                echo 'enabled=1'
                echo 'gpgcheck=1'
                echo 'gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key'
                echo 'exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni'
            } | sudo tee /etc/yum.repos.d/kubernetes.repo
            # Install kubelet, kubeadm and kubectl, and enable kubelet to ensure it's automatically started on startup:
            sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
            sudo systemctl enable --now kubelet
        ;;

        'arch')
            # Replace iptables for iptables-nft
            yes | sudo pacman -Sy kubeadm kubelet kubectl helm
            sudo systemctl enable --now kubelet
        ;;

        *) ;;
    esac
}

config_containerd(){
    echo -e "\n== ${YELLOW}Defining Cgroup for Containerd on '$distro'${RESET} =="

    if [[ $distro == 'arch' && ! -d /etc/containerd ]]; then
        sudo mkdir /etc/containerd
    fi

    # https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#configuring-a-cgroup-driver
    if ! grep -qs -e 'Cgroup' /etc/containerd/config.toml; then
        if [ -e /etc/containerd/config.toml ]; then
            sudo mv /etc/containerd/config.toml{,.bak}
        fi
        {
            echo '# Content of file /etc/containerd/config.toml -- https://stackoverflow.com/a/74695867'
            echo 'version = 2'
            echo '[plugins]'
            echo '  [plugins."io.containerd.grpc.v1.cri"]'
            echo '   [plugins."io.containerd.grpc.v1.cri".containerd]'
            echo '      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]'
            echo '        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]'
            echo '          runtime_type = "io.containerd.runc.v2"'
            echo '          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]'
            echo '            SystemdCgroup = true'
        } | sudo tee /etc/containerd/config.toml
        sudo systemctl restart containerd
    fi
}

setup_cluster(){

    echo -e "\n== ${YELLOW}====================${RESET} =="

    MoW=''
    while [[ $MoW != 'y' && $MoW != 'n' && $MoW != 'q' ]]; do
        read -p "Set up this HOST as the cluster's master node? [y/n/q] " MoW

        case $MoW in
            'y')
                setup_master_node
            ;;

            'n')
                setup_worker_node
            ;;

            'q')
                return 1
            ;;

            *) : ;;
        esac
    done
}

setup_master_node(){
    echo -e "\n== ${YELLOW}Setting up Kubeadm and Calico!!${RESET} =="

    # https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
    sudo kubeadm init --pod-network-cidr=10.0.0.0/16

    if [[ $? != 0 ]]; then
        echo -e "\n== ${YELLOW}'kubeadm init' failed, terminating script${RESET} =="
        exit 1
    fi

    echo -e "\n== ${YELLOW}====================${RESET} =="

    token_saved=''
    while [[ $token_saved != 'ok' ]]; do
        read -p "Save the token to some file. Enter 'ok' to continue: " token_saved
    done

    mkdir -p $HOME/.kube &&
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config &&
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # TODO: change NAT subnetting
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
    wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml &&
        sed -i 's/192.168.0.0/10.0.0.0/' custom-resources.yaml &&
        kubectl create -f custom-resources.yaml &&
        rm custom-resources.yaml


    echo -e "\n== ${GREEN}Script finished!! ${YELLOW}Verify them pods are being created!${RESET} =="
    echo '.....' && sleep 1
    echo '....' && sleep 1
    echo '...' && sleep 1
    echo '..' && sleep 1
    echo '.' && sleep 1

    watch kubectl get pods -n calico-system
    wait $!
    kubectl cluster-info &&
    kubectl get nodes &&
    kubectl get ns
}

setup_worker_node(){
    # WIP
    exit 1
}


# ==============================================================================


check_distro
install_docker              # docker + compose + containerd + buildx

disable_swap
install_kubernetes          # kubeadm + kubelet + kubectl

config_containerd
setup_cluster

