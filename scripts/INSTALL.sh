#!/usr/bin/env bash

# ##################################################
# Must be updated upon software releases
# Just guidance aight
# Assuming LAN is 192.168.1.0/24
# Kubeadm pod-network defined as 10.0.0.0/16
# ##################################################

RESET='\e[0m'
GREEN='\e[32m'
YELLOW='\e[33m'

check_distro(){
    distro=$(grep -s "^ID=" /etc/os-release | awk -F '=' '{print $2}')
    case $distro in
        'ubuntu'|'fedora'|'arch') ;;
        *)
            echo -e "== ${YELLOW}Distro '$distro' not supported, terminating script${RESET} =="
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
        *) echo "craft yeself" ;;
    esac
}

install_docker(){
    if docker &>/dev/null; then
        echo -e "== ${YELLOW}Docker already installed on '$distro'${RESET} =="
        docker --version
        return 1
    else
        echo -e "== ${YELLOW}Installing Docker on '$distro'${RESET} =="
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
            sudo pacman -Sy docker docker-buildx docker-compose
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
    if ! grep -q 'dev' /proc/swaps; then
        return 1
    fi
    
    case $distro in
        'ubuntu')
            sudo sed -i '/swap/s/^/# /' /etc/fstab &&
            sudo swapoff --all
        ;;
        'fedora')
            sudo dnf remove -y zram-generator-defaults &&
            sudo swapoff --all
        ;;
    esac
}

install_kubernetes(){
    if kubectl &>/dev/null; then
        echo -e "== ${YELLOW}Kubernetes already installed on '$distro'${RESET} =="
        kubectl version
        return 1
    else
        echo -e "== ${YELLOW}Installing Kubernetes on '$distro'${RESET} =="
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

setup_cluster(){
    MOAR_FIXES
    setup_control_plane
    setup_nodes_plane
}

MOAR_FIXES(){
    
    # FEDORA
    # sudo firewall-cmd --zone=public --add-port=6443/tcp --permanent
    # sudo firewall-cmd --zone=public --add-port=10250/tcp --permanent
    # sudo firewall-cmd --reload

    # UBUNTU -- likely DON'T
    # wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.10/cri-dockerd_0.3.10.3-0.ubuntu-jammy_amd64.deb
    # sudo dpkg -i cri-dockerd_0.3.10.3-0.ubuntu-jammy_amd64.deb

}

setup_control_plane(){

            # FIX [ERROR CRI] -- https://github.com/containerd/containerd/issues/8139; https://k21academy.com/docker-kubernetes/container-runtime-is-not-running/
            sudo mv /etc/containerd/config.toml{,.bak} && sudo systemctl restart containerd



    # Tener en cuenta la red local -- OJO con el TOKEN para los worker nodes
    sudo kubeadm init --pod-network-cidr=10.0.0.0/16


# W0308 12:55:11.692043    2769 checks.go:835] detected that the sandbox image "registry.k8s.io/pause:3.6" of the container runtime is inconsistent with that used by kubeadm. It is recommended that using "registry.k8s.io/pause:3.9" as the CRI sandbox image.





# https://stackoverflow.com/a/74695867












    mkdir -p $HOME/.kube &&
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config &&
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

        # kubectl get nodes --> NotReady is good
    

    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
    wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml &&
        sed -i 's/192.168.0.0/10.0.0.0/' custom-resources.yaml
        kubectl create -f custom-resources.yaml
    watch kubectl get pods -n calico-system     # FOCKING FREEZES

    # # FIX 'Connection to the server <ip>:6443 was refused - did you specify the right host or port?'
    reboot

    # FIX SandboxChanged
    kubectl get all -n tigera-operator
    kubectl describe pod/tigera-operator-*
    
}



# ==============================================================================


check_distro
install_docker              # ...

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
check_ports
disable_swap
install_kubernetes  # kubeadm + kubelet + kubectl
# OJO: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/

# setup_cluster --> arch chungo
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart

# install_minikube



# ==============================================================================

#             sudo sed -i '/disabled_plugins.*/s/^/# /' /etc/containerd/config.toml
#             echo '
# enabled_plugins = ["cri"]
# [plugins."io.containerd.grpc.v1.cri".containerd]
#   endpoint = "unix:///var/run/containerd/containerd.sock"' | sudo tee -a /etc/containerd/config.toml

