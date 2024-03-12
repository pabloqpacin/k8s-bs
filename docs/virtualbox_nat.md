# Cluster en VirtualBox con red NAT

<details>
<summary>Tabla de Contenidos</summary>

- [Cluster en VirtualBox con red NAT](#cluster-en-virtualbox-con-red-nat)
  - [Hardware](#hardware)
  - [Red NAT en VirtualBox](#red-nat-en-virtualbox)
    - [`101_arch` master node](#101_arch-master-node)
    - [`201_ubuntu` DHCP/DNS server + worker node](#201_ubuntu-dhcpdns-server--worker-node)
    - [`202_ubuntu` worker node](#202_ubuntu-worker-node)
    - [`203_ubuntu` worker node](#203_ubuntu-worker-node)
    - [`204_fedora` worker node](#204_fedora-worker-node)
    - [`205_fedora` worker node](#205_fedora-worker-node)
    - [`206_arch` worker node](#206_arch-worker-node)
  - [Documentación](#documentación)

</details>

## Hardware

Partición `k8s-cluster` de 420GB (`/dev/nvme0n1p1`) en mi máquina MSI GL76 bajo el sistema operativo Pop!_OS 22.04 LTS en la LAN 192.168.1.0/24

---

## Red NAT en VirtualBox

VirtualBox > Tools > Network > NAT Networks > Create > 
  - Name: k8s-cluster
  - IPv4 Prefix: 192.168.10.0/24
  - Enable DHCP: on

```bash
# vboxmanage list dhcpservers
```

### `101_arch` master node

VirtualBox > New >
  - memoria: 2048MB
  - cpu: 2
  - hard disk: 30GB
  - enable efi: yes
  - network:
    - nat network: k8s-cluster
      MAC: 08:00:27:8F:10:13

Instalación y configuración ([*base-i3*](https://github.com/pabloqpacin/dotfiles/blob/main/docs/linux/Arch_Hypr.md)) de Archlinux (SIN SWAP)

<!-- ```bash
if ! grep -q $(hostname) /etc/hosts; then
  echo -e "127.0.0.1\t\t$(hostname)" | sudo tee -a /etc/hosts
fi
``` -->

INSTALL.sh > nodo master

<details>
<summary>nodo master</summary>

```bash
# Iniciar nodo master
sudo kubeadm init --pod-network-cidr=10.0.0.0/16`

# # IMPORTANTE: guardar este output para introducirlo en los nodos 'workers'
# sudo kubeadm join <ip>:6443 --token <token> \
#         --discovery-token-ca-cert-hash sha256:<hash>
```
```bash
# Habilitar cubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Habilitar Calico para operar la red
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
  wget https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml &&
      sed -i 's/192.168.0.0/10.0.0.0/' custom-resources.yaml &&
      kubectl create -f custom-resources.yaml &&
      rm custom-resources.yaml

# Revisar la creación de elementos en el cluster
watch kubectl get pods -n calico-system
kubectl cluster-info &&
kubectl get nodes &&
kubectl get ns
```

**OJO**

```bash
# Generar otro token para habilitar workers
kubeadm token create --print-join-command
kubeadm token list
```

</details>

### `201_ubuntu` DHCP/DNS server + worker node

VirtualBox > New >
  - memoria: 2048MB
  - cpu: 2
  - hard disk: 40GB
  - enable efi: yes
  - network:
    - bridged adapter
      MAC: -
    - nat network: k8s-cluster
      MAC: 08:00:27:74:74:C4

Instalación y configuración de Ubuntu Server (instantánea *Base*):

```bash
# Instalar el sistema, tomar instantánea 'Fresh Install', luego instalar y configurar paquetes para instantánea `Base`
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pabloqpacin/dotfiles/main/scripts/autosetup/UbuntuServer-base.sh)"
```

Configuración de servicios DHCP/DNS

<details>
<summary> DHCP/DNS</summary>

> Plantillas: [1](https://github.com/pabloqpacin/ASIR/blob/main/Redes/Entregas/T2.md), [2](https://github.com/pabloqpacin/ASIR/blob/main/Redes/Entregas/UD3.1-DHCP_DNS_Apache_UbuntuServer.md) 

Instalar paquetes necesarios

```bash
sudo apt-get udpate && sudo apt-get install \
  openvswitch-switch isc-dhcp-server bind9 bind9-utils
```

Asignar dirección IP estática

```bash
sudo vim /etc/netplan/00-installer-config.yaml
```
```yaml
network:
  ethernets:
    # Bridged Network (LAN)
    enp0s3:
      dhcp4: true
    # NAT Network
    enp0s8:
      dhcp4: false
      addresses: [192.168.10.201/24]
      nameservers:
        addresses: [192.168.10.201]
  version: 2
```
```bash
sudo netplan apply
```

Definir interfaz para servicio DHCP

```bash
sudo vim /etc/default/isc-dhcp-server
```
```conf
# ...
INTERFACES="enp0s8"
```

Configuración servicio DHCP

```bash
sudo vim /etc/dhcp/dhcpd.conf
```
```c
option domain-name "cluster.net";
option domain-name-servers ns.cluster.net;

subnet 192.168.10.0 netmask 255.255.255.0 {
  range 192.168.10.30 192.168.10.80;
  option subnet-mask 255.255.255.0;
  option routers 192.168.10.1;
  option domain-name-servers 192.168.10.201;
  option domain-name "cluster.net";
}

host 101_arch {
  hardware ethernet 08:00:27:8F:10:13;
  fixed-address 192.168.10.101;
}

host 202_ubuntu {
  hardware ethernet 08:00:27:10:84:F4;
  fixed-address 192.168.10.202;
}

host 203_ubuntu {
  hardware ethernet 08:00:27:66:6F:BB;
  fixed-address 192.168.10.203;
}

host 204_fedora {
  hardware ethernet 08:00:27:D0:0D:5A;
  fixed-address 192.168.10.204;
}

host 205_fedora {
  hardware ethernet 08:00:27:8D:42:6B;
  fixed-address 192.168.10.205;
}

host 206_arch {
  hardware ethernet 08:00:27:77:EB:27;
  fixed-address 192.168.10.206;
}
```

Configuración servicio DNS

```bash
sudo vim /etc/bind/named.conf.local
```
```ini
// Zona Directa
zone "cluster.net" {
  type master;
  file "/etc/bind/db.cluster.net";
};

// Zona Inversa
zone "10.168.192.in-addr.arpa" {
  type master;
  file "/etc/bind/db.192";
};
```
```bash
named-checkzone

sudo cp /etc/bind/db.local /etc/bind/db.cluster.net
sudo vim /etc/bind/db.cluster.net
```
```ini
;
; BIND data file for local loopback interface
;
$TTL    604800
@   IN  SOA cluster.net. root.cluster.net. (
                  2     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL
;
@   IN  NS  cluster.net.
@   IN  A   192.168.10.201
@   IN  AAAA    ::1

ns      IN A    192.168.10.201
master  IN A    192.168.10.101
202     IN A    192.168.10.202
203     IN A    192.168.10.203
204     IN A    192.168.10.204
205     IN A    192.168.10.205
206     IN A    192.168.10.206
```

```bash
sudo cp /etc/bind/db.127 /etc/bind/db.192
sudo vim /etc/bind/db.192
```
```ini
;
; BIND reverse data file for local loopback interface
;
$TTL    604800
@   IN  SOA cluster.net. root.cluster.net. (
                  1     ; Serial
             604800     ; Refresh
              86400     ; Retry
            2419200     ; Expire
             604800 )   ; Negative Cache TTL
;
@   IN  NS  cluster.net.
;1.0.0  IN  PTR cluster.net.

201 IN  PTR     ns.cluster.net.
101 IN  PTR     master.cluster.net.
202 IN  PTR     202.cluster.net.
203 IN  PTR     203.cluster.net.
204 IN  PTR     204.cluster.net.
205 IN  PTR     205.cluster.net.
206 IN  PTR     206.cluster.net.
```
```bash
named-checkconf

named-checkzone cluster.net /etc/bind/db.cluster.net
named-checkzone 10.168.192.in-addr.arpa. /etc/bind/db.192
```

Aplicar configuración

```bash
sudo systemctl restart isc-dhcp-server named
```

</details>


INSTALL.sh > nodo worker

<details>
<summary>nodo worker</summary>

```bash
sudo kubeadm join 192.168.10.101:6443 --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash>
```

</details>

### `202_ubuntu` worker node

Clonación de `201_ubuntu` (instanánea *Base*) ('**Generar nuevas direcciones MAC para todos los adaptadores de red**' + cambiar `/etc/hostname`)

VirtualBox > Settings >
  - network:
    - nat network: k8s-cluster
      MAC: 08:00:27:10:84:F4

<!-- ```bash
sudo systemctl edit systemd-networkd-wait-online.service
    # [Service]
    # TimeoutStartSec=10
``` -->

INSTALL.sh > nodo worker

### `203_ubuntu` worker node

Clonación de `201_ubuntu` (instanánea *Base*)

VirtualBox > Settings >
  - network:
    - nat network: k8s-cluster
      MAC: 08:00:27:66:6F:BB

INSTALL.sh > nodo worker

### `204_fedora` worker node

VirtualBox > New >
  - memoria: 2048MB
  - cpu: 2
  - hard disk: 30GB
  - enable efi: yes
  - network:
    - nat network: k8s-cluster
      MAC: 08:00:27:D0:0D:5A

Instalación y configuración de Fedora Server (instantánea *Base*):

```bash
# Set hostname
echo '204-fedora' | sudo tee /etc/hostname

# Instalar el sistema, tomar instantánea 'Fresh Install', luego instalar y configurar paquetes para instantánea 'Base'
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pabloqpacin/dotfiles/main/scripts/autosetup/FedoraServer-base.sh)"
```

INSTALL.sh > nodo worker

### `205_fedora` worker node

Clonación de `204_fedora` (instanánea *Base*)

VirtualBox > Settings >
  - network:
    - nat network: k8s-cluster
      MAC: 08:00:27:8D:42:6B

<!-- ```bash
echo '205-fedora' | sudo tee /etc/hostname
``` -->

INSTALL.sh > nodo worker

### `206_arch` worker node

Clonación de `101_arch` (instanánea *i3-base*)

VirtualBox > Settings >
  - network:
    - nat network: k8s-cluster
      MAC: 08:00:27:8F:10:13

```bash
sudo sed -i 's/101/206/' /etc/hosts &&
echo '206-arch' | sudo tee /etc/hostname
```

INSTALL.sh > nodo worker


---

## Documentación

- VirtualBox NAT
  - https://superuser.com/questions/1350514/assign-a-static-ip-address-to-a-virtualbox-guest-with-a-nat-network-without-acce
  - https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-dhcpserver.html
  - https://www.techbeatly.com/how-to-create-and-use-natnetwork-in-virtualbox/
  - https://www.virtualbox.org/manual/ch09.html#changenat
  - https://www.youtube.com/watch?v=pvlpabhrWg0

<details>
<summary>vboxmanage</summary>

```txt
$ vboxmanage list dhcpservers

NetworkName:    HostInterfaceNetworking-vboxnet0
Dhcpd IP:       192.168.56.100
LowerIPAddress: 192.168.56.101
UpperIPAddress: 192.168.56.254
NetworkMask:    255.255.255.0
Enabled:        Yes
Global Configuration:
    minLeaseTime:     default
    defaultLeaseTime: default
    maxLeaseTime:     default
    Forced options:   None
    Suppressed opts.: None
        1/legacy: 255.255.255.0
Groups:               None
Individual Configs:   None

NetworkName:    k8s-cluster
Dhcpd IP:       192.168.10.3
LowerIPAddress: 192.168.10.4
UpperIPAddress: 192.168.10.254
NetworkMask:    255.255.255.0
Enabled:        Yes
Global Configuration:
    minLeaseTime:     default
    defaultLeaseTime: default
    maxLeaseTime:     default
    Forced options:   None
    Suppressed opts.: None
        1/legacy: 255.255.255.0
        3/legacy: 192.168.10.1
        6/legacy: 192.168.10.1
       15/legacy: .
Groups:               None
Individual Configs:   None
```

```bash
# Not working properly; improve them commands!!

vboxmanage dhcpserver add --network=TEST --server-ip=192.168.20.1 --netmask=255.255.255.0 --lower-ip=192.168.20.6 --upper-ip=192.168.20.9 --enable

# vboxmanage dhcpserver modify --network=TEST --mac-address=08:00:27:5A:9C:44 --fixed-address=192.168.20.101
vboxmanage dhcpserver modify --network=TEST --mac-address=08:00:27:5A:9C:44 --fixed-address=192.168.10.101
```
</details>
