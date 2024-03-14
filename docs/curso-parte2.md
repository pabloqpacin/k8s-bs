# Curso Kubernetes al completo(#curso-kubernetes-al-completo)

- [Curso Kubernetes al completo(#curso-kubernetes-al-completo)](#curso-kubernetes-al-completocurso-kubernetes-al-completo)
  - [NOTAS](#notas)
    - [Dashboard UI en Cluster](#dashboard-ui-en-cluster)
  - [PARTE 1](#parte-1)
    - [~~1. Introducción~~](#1-introducción)
    - [~~2. Kubectl: trabajar con clusters~~](#2-kubectl-trabajar-con-clusters)
    - [~~3. Minikube: trabajar en local~~](#3-minikube-trabajar-en-local)
    - [~~4. Docker Desktop: trabajar en local~~](#4-docker-desktop-trabajar-en-local)
    - [~~5. VSCode~~](#5-vscode)
    - [~~6. PODS~~](#6-pods)
    - [~~7. LABELS, Selectors, Anotaciones -- Etiquetar objetos~~](#7-labels-selectors-anotaciones----etiquetar-objetos)
    - [~~8. Deployments~~](#8-deployments)
    - [~~9. Servicios~~](#9-servicios)
    - [~~10. Ejemplo Aplicación PHP-REDIS con Servicios (!)~~](#10-ejemplo-aplicación-php-redis-con-servicios-)
    - [~~11. Namespaces -- agrupar objetos~~](#11-namespaces----agrupar-objetos)
    - [~~12. Rolling Updates~~](#12-rolling-updates)
    - [~~13. Variables, ConfigMaps y Secrets~~](#13-variables-configmaps-y-secrets)
    - [~~14. Kubeconfig: configuración del cluster~~](#14-kubeconfig-configuración-del-cluster)
  - [PARTE 2](#parte-2)
    - [15. Crear un cluster real con Kubeadm con VMs (!)](#15-crear-un-cluster-real-con-kubeadm-con-vms-)
    - [16. Scheduler -- Asignar Pods a Nodos](#16-scheduler----asignar-pods-a-nodos)
    - [17. Asignación de recursos y Autoescalado](#17-asignación-de-recursos-y-autoescalado)
    - [18. Almacenamiento en Kubernetes](#18-almacenamiento-en-kubernetes)
    - [19. Storage Class -- almacenamiento dinámico](#19-storage-class----almacenamiento-dinámico)
    - [20. Otros Workloads -- más allá de los Deployments](#20-otros-workloads----más-allá-de-los-deployments)
    - [21. Sondas -- PODS monitoring](#21-sondas----pods-monitoring)
    - [22. RBAC -- Seguridad en clusters](#22-rbac----seguridad-en-clusters)
    - [23. Ingress -- conectar servicios al exterior](#23-ingress----conectar-servicios-al-exterior)
    - [24. Amazon EKS. Amazon Elastic Kubernetes](#24-amazon-eks-amazon-elastic-kubernetes)
    - [25. Azure AKS. Azure Kubernetes Services](#25-azure-aks-azure-kubernetes-services)
    - [26. Próximas secciones](#26-próximas-secciones)


## NOTAS


### Dashboard UI en Cluster

```bash
# master node
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# ###### TOKEN
# - [ ] https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

kubectl get all -n kubernetes-dashboard
kubectl proxy

curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```


## PARTE 1
### ~~1. Introducción~~
### ~~2. Kubectl: trabajar con clusters~~
### ~~3. Minikube: trabajar en local~~
### ~~4. Docker Desktop: trabajar en local~~
### ~~5. VSCode~~
### ~~6. PODS~~
### ~~7. LABELS, Selectors, Anotaciones -- Etiquetar objetos~~
### ~~8. Deployments~~
### ~~9. Servicios~~
### ~~10. Ejemplo Aplicación PHP-REDIS con Servicios (!)~~
### ~~11. Namespaces -- agrupar objetos~~
### ~~12. Rolling Updates~~
### ~~13. Variables, ConfigMaps y Secrets~~
### ~~14. Kubeconfig: configuración del cluster~~

## PARTE 2

### 15. Crear un cluster real con Kubeadm con VMs (!)

> [github.com/pabloqpacin/k8s-bs/blob/main/scripts/INSTALL.sh](https://github.com/pabloqpacin/k8s-bs/blob/main/scripts/INSTALL.sh)

- NOTAS
  - No `minikube` sino `kubeadm`
  - 1 master + N esclavos
- Install `kubeadm` `kubelet` `kubectl`
  - NO SWAP
  - [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
  - [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
  - [Configuring a cgroup driver (*done but idk shey)*](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)
- Kubernetes Networking Model

```md
- Kubernetes no gestiona la red: lo cede al **container runtime** CR (docker engine, containerd, ...)
- MODELO de red
  - consistencia en múltiples topologías
  - determina relaciones entre componentes (contenedores, pods, servicios...)
  - CARACTERÍSTICAS: 1 pod 1 IP, N contenedores 1 IP, N pods se ven (IPs, sin NAT), existen filtros
  - 1 pod 1 host virtual (~ vm)
- IMPLEMENTACIÓN
  - mediante **plugins** de 3os -> según estándar CNI gestionado por CR
  - tipos: Network (conexión pods a red) VS IPAM (direccionamiento, poderoso)
  - > https://www.cni.dev/docs/
  - > https://kubernetes.io/docs/concepts/cluster-administration/addons/
  - **Calico**: networking + network policy
- Kubernetes DNS
  - 1 cluster 1 servicio DNS -> localizar pods, servicios etc
  - ejemplos:
    - `mi-servicio.mi-namespace.svc.cluster-domain.curso`
    - `pod-ip-address.mi-namespace.pod.cluster-domain.curso`
```

- Bootstrapping del cluster con Kubeadm
  - https://github.com/pabloqpacin/k8s-bs/blob/main/scripts/INSTALL.sh
  - https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart

<!-- ```bash
# https://medium.com/@cminion/quicknote-kubernetes-networking-issues-78f1e0d06e12
-->

- Permitir que el master ejecute pods (por defecto solo workers) con `taint`

```bash
$ kubectl taint nodes --all node-role.kubernetes.io/control-plane-
node/cluster1-ubuntuserver untainted

$ kubectl taint nodes --all node-role.kubernetes.io/master-
error: taint "node-role.kubernetes.io/master" not found
```

- Añadir nodos
  - 1. Usar lo que habíamos guardado cuando el `kubeadm init` (`kubeadm join <ip>:6443 --token <ip> --discovery-token-ca-cert-hash sha256:<hash>`)
  - 2. Generar un token:

```bash
# En master
kubeadm token create --print-join-command
kubeadm token list
```

```bash
# En worker
sudo kubeadm join 192.168.1.37:6443 --token yft6r5.7poirxen3yry40js \
  --discovery-token-ca-cert-hash sha256:95bfe0003e13ae14d4d78492c7239a730a5c72aa1e8b92c7fcd1ac4e81040f24
```

```bash
# En master
kubectl get nodes
```

- Probar cluster creando deployment

```bash
# En master
kubectl create deploy apache1 --replicas=3 --image=httpd
kubectl get pods -o wide

kubectl scale deploy apache1 --replicas=5
kubectl get pods -o wide
```

- Procesos y ficheros generados con el cluster

```bash
# En master
ps -ef | grep kube
  # kube-controller-manager
  # kube-scheduler
  # kube-apiserver
  # kubelet
  # etcd
```
```bash
# En worker
ps -ef | grep kube
  # kube-proxy
  # kubelet
```
```bash
# En master
sudo tree /etc/kubernetes
  # ficheros de configuración
  # claves de autenticación
```
```bash
# En worker
sudo tree /etc/kubernetes
  # ...
```

### 16. Scheduler -- Asignar Pods a Nodos

- Intro

```txt
POD -> Scheduling queue -> Filter (taints, recursos, selectors)
                              -> Scoring (afinidad, existencia imagen, carga)
                                    -> Kubelet Container Runtime -> Node X
```

- Asignar un pod de forma manual (NO RECOMENDABLE)

```bash
mkdir ~/k8s && cd $_
nvim nginx.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    zone: prod
    version: v1
spec:
  containers:
    - name: nginx
      image: nginx
  nodeName: worker-01   # ESTO
```
```bash
kubectl apply -f nginx.yaml
kubectl get pods
```

- Node Selector

```bash
cd ~/k8s
nvim nginx.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    zone: prod
    version: v1
spec:
  containers:
    - name: nginx
      image: nginx
  nodeSelector:
    entorno: desarrollo
```
```bash
kubectl label node <node> entorno=desarrollo
# kubectl label node cluster4-ubuntuserver entorno=desarrollo
kubectl apply -f nginx.yaml
kubectl get pods

kubectl get nodes --show-labels
```

- Ejemplo nodeSelector con deployments

```bash
cd ~/k8s
nvim deploy-nginx.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-d
spec:
  selector:               # permite seleccionar un conjunto de objetos que cumplan las condiciones
    matchLabels:
      app: nginx
  replicas: 6             # ejecutar 6 pods (según las LABELS en 2 nodos)
  template:               # plantilla que define los containers
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
      nodeSelector:
        aplicacion: web
```
```bash
kubectl label node 204-fedora aplicacion=web
kubectl label node 205-fedora aplicacion=web

kubectl apply -f deploy-nginx.yaml
```

- ['Etiquetas bien definidas'](https://kubernetes.io/docs/reference/labels-annotations-taints/) (arch, os, hostname...)

```bash
kubectl get pods --show-labels
kubectl get nodes --show-labels
kubectl describe node 206-arch | grep -A5 'Labels'
```

- Afinidad de nodos (cómo los pods eligen un nodo) <!--tb existe afinidad interpods -->
  - planificación más granular que con el NodeSelector
  - reglas de distinto tipo
  - reglas para la fase de Scheduling o de Ejecución
  - preferido u obligatorio
  - también se utilizan etiquetas para identificar los nodos correctos
  - se puede utilizar *anti-affinity*
  - distintos operadores y opciones para poner estas reglas
    - `In` `NotIn` `Exists` `DoesNotExist` `Gt` `Lt`
    - `nodeSelectorTerms` `matchExpressions`

```bash
requiredDuringSchedulingIgnoredDuringExecution
requiredDuringSchedulingRequiredDuringExecution
preferredDuringSchedulingIgnoredDuringExecution
preferredDuringSchedulingRequiredDuringExecution
```
```yaml
spec:
  affinity:
    nodeAffinity:
      # Elegir nodos con etiqueta 'testing'
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: name
              operator: In
              values:
                - testing
      # Preferiblemente si su tipo es 'app-hr'
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
        preference:
          matchExpressions:
            - key: type
              operator: In
              values:
                - app-hr
```

- Afinidad de nodos (ejemplo práctico)

```bash
cd ~/k8s
nvim pod_affinity.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache1
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: equipo
            operator: In
            values:
            - desarrollo-web
            - desarrollo-python
  containers:
  - name: apache1
    image: httpd
```
```bash
kubectl apply -f deploy-nginx.yaml

# Si no se encuentran nodos con las labels, los pods no se crean (Pending)
# kubectl describe pod apache1: FailedScheduling 0/n nodes are available

# kubectl label --list nodes <node>   # list labels
# kubectl label node <node>-          # remove label
kubectl label node 202-ubuntu equipo=desarrollo-web
```

<!-- Taint es como una condición que solo puede superarse con Toleration -->
- Taints y Tolerations
  - un Taint permite que un nodo NO acepte uno o varios pods (contrario al NodeAffinity)
  - los Taints se aplican a los nodos y las Tolerations a los pods
  - Taints pueden ser: `NoSchedule` `PreferNoSchedule` `NoExecute`

```yaml
# Ejemplo Taint en nodo (config nodo): pod sin Toleration no se puede desplegar
entorno=produccion:NoSchedule

# Ahora sí que podría (config pod)
tolerations:
- key: "entorno"
  operator: "Equal"
  value: "produccion"
  effect: "NoSchedule" 
```

- Taints y Tolerations (laboratorio práctico)

```bash
# kubectl taint nodes 206-arch memoria=grande:NoSchedule-   # delete taint
kubectl taint nodes 206-arch memoria=grande:NoSchedule
kubectl describe nodes | grep 'Taints'
kubectl describe node 206-arch | grep 'Taints'
kubectl describe node 101-arch | grep 'Taints'  # node-role.kubernetes.io/control-plane:NoSchedule

kubectl create deploy apache1 --replicas=10 --image=httpd
kubectl get pods -o wide        # ni 101-arch ni 206-arch

cd ~/k8s
nvim deploy-nginx-toleration.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-d
spec:
  selector:               # permite seleccionar un conjunto de objetos que cumplan las condiciones
    matchLabels:
      app: nginx
  replicas: 10            # ejecutar 10 pods (según taints & tolerations)
  template:               # plantilla que define los containers
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
      tolerations:
      - effect: NoSchedule
        key: memoria
        operator: Equal
        value: grande
```
```bash
kubectl apply -f deploy-nginx.yaml
kubectl get pods -o wide | grep '206-arch'
```

### 17. Asignación de recursos y Autoescalado

> - https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
> - https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/
> - https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/

- Introducción
  - Importante: configurar CPU y Memoria
  - Método: manualmente (a nivel de pod, namespace o nodo) o automáticamente (cluster determina escalado...)

- Configurar memoria de un pod/deployment

```bash
mkdir -p ~/k8s/recursos && cd $_
nvim deploy-nginx.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-d
  labels:
    estado: "1"
spec:
  selector:               # permite seleccionar un conjunto de objetos que cumplan las condiciones
    matchLabels:
      app: nginx
  replicas: 4
  template:               # plantilla que define los containers
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
        resources:
          # límito máximo
          limits:
            memory: "200Mi"
            cpu: "2"            
          # petición inicial
          requests:
            memory: "100Mi"
            cpu: "0.5"
```
```bash
kubectl apply -f deploy-nginx.yaml
```

- Instalar *MetricServer* en Minikube

```bash
kubectl top pod <pod>
minikube addons list | grep 'metrics-server'
minikube addons -p cluster1 list
minikube addons enable metrics-server -p cluster1
minikube addons -p cluster1 list
kubectl top pod <pod>
```

- Instalar *MetricServer* en cluster real Kubeadm

> - https://github.com/kubernetes-sigs/metrics-server

```bash
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# # FALLO out of the box
# kubectl get ns | grep 'kube-system'   # Aquí se instalará 'metrics-server'
# kubectl get svc metrics-server -n kube-system
# kubectl get deploy metrics-server -n kube-system
# kubectl describe deploy metrics-server -n kube-system
```
```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
nvim components.yaml
  # en Deployment, donde 'args', debajo de 'secure-port':
    # - --kubelet-insecure-tls
#  # donde 'preferred-address-types': sed 's/InternalIP/InternalDNS,InternalIP,ExternalDNS/'
#  # donde 'metric-resolution': sed 's/15s/30s/'
#  # antes de 'priorityClassName':
#  #   hostNetwork: true

kubectl apply -f components.yaml

kubectl top nodes
kubectl top pod <pod>

# # ~~ERROR!~~
# kubectl logs -n kube-system <metrics-pod>

# kubectl -n kube-system get pods
# kubectl get --raw /api/v1/nodes/<node>/proxy/metrics/resource

#   # alternativas...
#   # - Prometheus
```

- Configurando límites a los Namespaces <!--no se aplica para recursos existentes-->
  - dos mecanismos:
    - `LimitRange`: límites y uso por defecto para pods
    - `ResourceQuota`: recursos totales para el ns

<details>
<summary>Ejemplos
</summary>

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
spec:
  hard:
    configmaps: "10"
    persistentvolumeclaims: "4"
    replicationcontrollers: "20"
    secrets: "10"
    services: "10"
    requests.cpu: "200m"
    limits.cpu: "300m"
```
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-min-max-demo
spec:
  limits:
  - max:
      memory: 1Gi
    min:
      memory: 500Mi
    type: Container
```
</details>

- LimitRange

```bash
cd ~/k8s/recursos
nvim limites.yaml
```
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: recursos
spec:
  limits:
  - default:
      memory: 512Mi
      cpu: 1
    defaultRequest:
      memory: 256Mi
      cpu: 0.5
    max:
      memory: 1Gi
      cpu: 4
    min:
      memory: 128Mi
      cpu: 0.5
    type: Container
```
```bash
kubectl apply -f limites.yaml -n default
kubectl describe ns default
```

- ResourceQuota

```bash
cd ~/k8s/recursos
nvim quotas.yaml
```
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pods-grandes
spec:
  hard:
    requests.cpu: "100"
    requests.memory: 500Mi
    limits.cpu: "500"
    limits.memory: 1Gi
    pods: "5"
```
```bash
kubectl apply -f quotas.yaml
kubectl get quota
kubectl describe ns default
```

- Dar prioridad a nuestros pods: `priorityClass`

```bash
cd ~/k8s/recursos
nvim prioridad.yaml
# a más 'value', más prioridad
# llegado al límite, expulsa los que tengan baja prioridad
```
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: produccion
value: 100
preemptionPolicy: PreemptLowerPriority  # || None (no eches)
globalDefault: false                    # solo puede haber uno True
description: "Pods para entornos de Producción"

---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: desarrollo
value: 50
preemptionPolicy: PreemptLowerPriority
globalDefault: false
description: "Pods para entornos de Desarrollo"
```
```bash
kubectl apply -f prioridad.yaml
kubectl get priorityclass
```
```bash
nvim deploy_pc_low.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-deploy
  labels:
    estado: "1"
spec:
  selector:
    matchLabels:
      app: apache
  replicas: 100
  template:
    metadata:
      labels:
        app: apache
    spec:
      priorityClassName: "desarrollo"
      containers:
      - name: apache
        image: httpd 
        ports:
        - containerPort: 80
        resources:
          limits:
              memory: "400Mi"
              cpu: "1"
          requests:
              memory: "256Mi" 
              cpu: "0.5"
```
```bash
kubectl apply -f deploy_pc_low.yaml
watch kubectl get deploy
  # ... básicamente se llega al límite en 20/100

nvim deploy_pc_alta.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache-prod
  labels:
    estado: "1"
spec:
  selector:
    matchLabels:
      app: apache
  replicas: 5
  template:
    metadata:
      labels:
        app: apache
    spec:
      priorityClassName: "produccion"
      containers:
      - name: apache
        image: httpd 
        ports:
        - containerPort: 80
        resources:
          limits:
              memory: "400Mi"
              cpu: "1"
          requests:
              memory: "256Mi" 
              cpu: "0.5"
```
```bash
kubectl apply -f deploy_pc_alta.yaml
watch kubectl get deploy
  # ... ahora es 5/5 y 15/100

```

- Trabajar con múltiples quotas (en un ns): `scopeSelector`

```bash
kubectl delete quota --all
nvim quota2.yaml
```
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pods-grandes
spec:
  hard:
    requests.cpu: "100"
    requests.memory: 500Mi
    limits.cpu: "500"
    limits.memory: 1Gi
    pods: "5"
  scopeSelector:
    matchExpressions:
    - operator : In
      scopeName: PriorityClass  # DEBE EXISTIR PREVIAMENTE
      values: ["produccion"]
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: pods-peques
spec:
  hard:
    requests.cpu: "50"
    requests.memory: 100Mi
    limits.cpu: "100"
    limits.memory: 200Mi
    pods: "10"
  scopeSelector:
    matchExpressions:
    - operator : In
      scopeName: PriorityClass
      values: ["desarrollo"]
```
```bash
kubectl get pc | grep -e 'desarrollo' -e 'produccion'
kubectl apply -f quota2.yaml
kubectl get quota
kubectl describe ns default
```

```bash
nvim quota2_pods.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx1
  labels:
    zone: prod
    version: v1
spec:
  containers:
   - name: nginx   
     image: nginx
     resources:
      limits:
        memory: "100Mi"
        cpu: "1"
      requests:
        memory: "10Mi"
        cpu: "0.5"
  priorityClassName: desarrollo
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx2
  labels:
    zone: prod
    version: v1
spec:
  containers:
   - name: nginx   
     image: nginx
     resources:
      limits:
        memory: "100Mi"
        cpu: "1"
      requests:
        memory: "10Mi"
        cpu: "0.5"
  priorityClassName: produccion
```
```bash
kubectl apply -f quota2_pods.yaml
kubectl get quota
```

- Los recursos en los **NODOS**

```bash
kubectl get nodes
# kubectl top nodes               # error: Metrics API not available
kubectl describe node <node>  # | tail -n30
``` 

- HugePages
  - páginas de memoria -- estándar tamaño 4K -- ahora 2M o 1G -- casoDeUso: Cassandra

```bash
# # A NIVEL DE SISTEMA OPERATIVO
# cat /proc/meminfo | grep -e 'Huge'
# sysctl -a | grep 'huge'

# # 100 * 2M
# echo 'vm.nr_hugepages=100' | sudo tee -a /etc/sysctl.conf
# sysctl -p
```
```yaml
spec:
  containers:
    volumeMounts:
    - mountPath: /hugepages
      name: hugepage
    resources:
      requests:
        hugepages-2Mi: 1Gi
      limits:
        hugepages-2Mi: 1Gi
  volumes:
  - name: hugepage
    emptyDir:
      medium: HugePages
```

- Autoescalado
  - aumentar o reducir recursos de forma automática (según carga de trabajo)
  - 3 tipos:
    - **HPA**: Horizontal Pod AutoScaler
      - escala núm. pods en un determinado *despliegue*
      - gestionado por el propio Controller Manager
      - 'en cada bucle el Controller compara el uso actual de los recursos con las métricas definidas para cada HP; estas métricas pueden ser utilizadas por un **metric server** o bien se pueden obtener directamente desde los pods'
      - los pods deberían tener configurados los **requests** de recursos
    - VPA: Vertical Pod AutoScaler 
      - escalado vertical: asigna más recursos (memoria,cpu) a los pods existentes
      - también utiliza métricas para determinar si es necesario escalar
    - CA: Cluster AutoScaler
      - entornos Cloud

> - [ ] https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

```bash
# OJO: NECESARIO metrics-server

mkdir -p ~/k8s/autoescalado && cd $_
nvim deploy_svc_hpa.yaml
```
```yaml
# EXPLICACIÓN: se incrementará el número de 
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache
spec:
  selector:
    matchLabels:
      run: apache
  replicas: 1
  template:
    metadata:
      labels:
        run: apache
    spec:
      containers:
      - name: apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
# TODO: NodePort?
apiVersion: v1
kind: Service
metadata:
  name: apache
  labels:
    run: apache
spec:
  ports:
  - port: 80
  selector:
    run: apache

```
```bash
kubectl get pod
kubectl get rs
kubectl get svc
kubectl get hpa

kubectl autoscale --help
# Autoescalado de al menos 1 pod y max 8 si se supera un uso de la cpu del 40%
kubectl autoscale deploy apache --cpu-percent=40 --min=1 --max=8
kubectl get hpa

# Hacer llamadas al servicio>deploy para forzar el autoescale
kc exec -it <pod> -- curl apache
kubectl run -i --tty carga --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://apache; done"

watch kubectl get hpa
  # AUMENTA EL NÚMERO DE RÉPLICAS
```

### 18. Almacenamiento en Kubernetes



---

```bash
```
```yaml
```
```bash
```

---

### 19. Storage Class -- almacenamiento dinámico
### 20. Otros Workloads -- más allá de los Deployments
### 21. Sondas -- PODS monitoring
### 22. RBAC -- Seguridad en clusters
### 23. Ingress -- conectar servicios al exterior
### 24. Amazon EKS. Amazon Elastic Kubernetes
### 25. Azure AKS. Azure Kubernetes Services
### 26. Próximas secciones


---



<!-- ### Dashboard UI en Cluster

- POBLEMA

```bash
# master node
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# - [ ] https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

kubectl proxy

curl http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# {
#   "kind": "Status",
#   "apiVersion": "v1",
#   "metadata": {},
#   "status": "Failure",
#   "message": "error trying to reach service: dial tcp 10.0.224.203:8443: connect: no route to host",
#   "reason": "ServiceUnavailable",
#   "code": 503
# }


# https://github.com/kubernetes/dashboard/issues/5542
# https://stackoverflow.com/questions/64295923/accessing-kubernetes-dashboard-gives-error-trying-to-reach-service-dial-tcp-10
# - [ ] https://upcloud.com/resources/tutorials/deploy-kubernetes-dashboard
# - [ ] https://adamtheautomator.com/kubernetes-dashboard/
# - [ ] https://www.aquasec.com/cloud-native-academy/kubernetes-101/kubernetes-dashboard/
# - [x] https://serverfault.com/questions/1077038/not-able-to-access-kubernetes-dashboard
# - [x] https://www.reddit.com/r/kubernetes/comments/13ydpna/no_route_to_host_when_accessing/
```
> - https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

```bash

kubectl get all -n kubernetes-dashboard

kubectl proxy
# # kubectl proxy --address 0.0.0.0 --accept-hosts '.*'

# kubectl proxy --port=8001 --address='192.168.10.201' --accept-hosts="^*$"
``` -->
