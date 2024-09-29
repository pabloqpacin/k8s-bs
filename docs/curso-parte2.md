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
    - [18. Almacenamiento en Kubernetes: volúmenes](#18-almacenamiento-en-kubernetes-volúmenes)
      - [Ejemplo con NFS: aplicación Wordpress con MySQL](#ejemplo-con-nfs-aplicación-wordpress-con-mysql)
    - [19. Storage Class -- almacenamiento dinámico](#19-storage-class----almacenamiento-dinámico)
      - [Laboratorio: AWS y discos ESB](#laboratorio-aws-y-discos-esb)
    - [20. Otros Workloads -- más allá de los Deployments](#20-otros-workloads----más-allá-de-los-deployments)
    - [21. Sondas -- PODS monitoring](#21-sondas----pods-monitoring)
    - [22. RBAC -- Seguridad en clusters](#22-rbac----seguridad-en-clusters)
    - [23. Ingress -- conectar servicios al exterior](#23-ingress----conectar-servicios-al-exterior)
    - [24. Amazon EKS. Amazon Elastic Kubernetes](#24-amazon-eks-amazon-elastic-kubernetes)
    - [25. Azure AKS. Azure Kubernetes Services](#25-azure-aks-azure-kubernetes-services)
    - [26. Próximas secciones](#26-próximas-secciones)


## NOTAS

- https://kubernetes.io/docs/reference/kubectl/quick-reference/

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
#  # # donde 'preferred-address-types': sed 's/InternalIP/InternalDNS,InternalIP,ExternalDNS/'
#  # # donde 'metric-resolution': sed 's/15s/30s/'
#  # # antes de 'priorityClassName':
#  # #   hostNetwork: true

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

### 18. Almacenamiento en Kubernetes: volúmenes

> - https://kubernetes.io/docs/concepts/storage/volumes/
> - https://kubernetes.io/docs/concepts/storage/persistent-volumes/

- Intro
  - Almacenamiento en kubernetes es efímero (`/tmp`) -- Concepto de 'inmutabilidad', tema 'Estado deseado', al eliminar se restauran recursos (memoria, cpu, almacenamiento)
  - Volúmenes: persistencia; tipos: locales, externos, cloud (según *drivers*)
  - *CSI*: Container Storage Interface:: 'estándar que permite exponer almacenamiento a todo tipo de workloads de kubernetes'
- Cómo crear volúmenes
  - Dos cláusulas:
    - 1 para indicar dónde montar los volúmenes en el pod (`spec.containers.volumeMounts`)
    - 1 para indicar qué volúmenes vamos a usar (`spec.volumes`)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volumenes
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /home
      name: home
  volumes:
  - name: home
    hostPath:
      path: /home/kubernetes/datos
```

- Crear volúmenes en un pod

```bash
sudo mkdir /home/kubernetes/datos

mkdir -p ~/k8s/volumenes && cd $_
nvim volumen.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volumenes
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /home
      name: home
    - mountPath: /git
      name: git
      readOnly: true
    - mountPath: /temp
      name: temp
  volumes:
  - name: home
    hostPath:     # HOST, MÁQUINA REAL;; persistencia pero ojo nodos...
      path: /home/kubernetes/datos
  - name: git
    # DEPRECATED -- https://kubernetes.io/docs/concepts/storage/volumes/#gitrepo
    gitRepo:
      repository: https://github.com/ApasoftTraining/cursoKubernetes.git
  - name: temp
    emptyDir: {}  # Directorio temporal

```
```bash
kubectl apply -f volumenes
kubectl describe pod volumenes
kubectl exec -it volumenes -- bash
  # touch foo
# ssh <nodo> && cd /home/kubernetes/datos
  # ls foo
```

- Volúmenes persistentes
  - Storage Class { PV (~vdi) > PVClaim } > Pod <!-- almacenamiento dinámico -->
  - Tipos de acceso:
    - `ReadWriteOnce`: RWO solo para un nodo
    - `ReadOnlyMany`: ROX muchos nodos
    - `ReadWriteMany`: RWM muchos nodos
    - `ReadWriteOncePod`: RWOP un solo Pod
  - Tipos de aprovisionamiento:
    - Estático: asociar PV de forma estático
    - Dinámico: se usan Storage Classes para encontrar un PV adecuado
  - Tipos de Reciclaje de PV (al eliminar el pod asociado):
    - Retain: reclamación manual (no se elimina pero tampoco puede ser reusado sin más)
    - Recycle: prepara para reutilizar (DEPRECATED)
    - Delete: se elimina

...

- Crear un PV con HostPath (no recomendable en producción por N nodos, lo suyo sería almacenamiento compartido)

```bash
cd ~/k8s/volumenes
nvim pv_claim_pod.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume
  labels:
    type: local
spec:
  storageClassName: sistemaficheros     # ojo
  capacity:
    storage: 3Gi
  accessModes:                          # 1+ ok
    - ReadWriteOnce
  hostPath:                             # DRIVER
    path: "/mnt/data"                   # en el nodo!!

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  storageClassName: sistemaficheros
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi                      # se asocian los 3 del PV, desaprovechado por diseño

---
apiVersion: v1
kind: Pod
metadata:
  name: pv-pod
spec:
  volumes:
    - name: pv-storage
      persistentVolumeClaim:
        claimName: pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: pv-storage

```
```bash
kubectl apply -f pv_claim_pod.yaml

kubectl get pv
kubectl get pvc
kubectl get pods -o wide
kubectl describe pv | grep -e 'Finalizers' -e 'Source'  -A5
kubectl describe pvc
kubectl describe pod pv-pod | grep -e 'Mount' -e 'Volumes' -A5
# ssh <nodo> && ls /mnt/data
```

- Demonstración con NFS
  - lo ideal sería tener otra máquina (externa al cluster) para el almacenamiento
  - montar el entorno

```bash
# 201.cluster.net
sudo apt-get update && sudo apt-get install -y \
    nfs-kernel-server

if [[ ! -d /var/datos && $(! grep -q '/var/datos' /etc/exports; echo $?) ]]; then
    sudo mkdir -p /var/datos
    sudo chmod o+rwx /var/datos
    echo '/var/datos *(rw,sync,no_root_squash,no_all_squash)' | sudo tee -a /etc/exports
    sudo systemctl restart nfs-kernel-server
else
    echo 'Existing NFS config detected. Not applying changes'
fi
```
```bash
# 101, 202-206
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
```

- Ejemplo con NFS: aplicación NGINX

```bash
# git clone --depth 1 https://github.com/pabloqpacin/ASIR /tmp/ASIR && \
#     cp -r /tmp/ASIR/Redes/Entregas/web ~/web && \
#     rm -rf /tmp/ASIR

cp -r ~/web/* /var/datos

mkdir -p ~/k8s/nfs && cd $_
nvim pv-pvc-pod_nfs.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: volumen-nfs
  nfs:
    path: /var/datos
    server: 192.168.10.201
    # server: 201.cluster.net

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  storageClassName: volumen-nfs
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi

---
apiVersion: v1
kind: Pod
metadata:
  name: pod-nfs
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
      - mountPath: /usr/share/nginx/html
        name: nfs-vol
  volumes:
    - name: nfs-vol
      persistentVolumeClaim:
        claimName: nfs-pvc
```
```bash
kubectl apply -f pv-pvc-pod_nfs.yaml

kubectl get pv && kubectl get pvc && kubectl get pods
kubectl describe pod pod-nfs

kubectl proxy
curl localhost:8001/api/v1/namespaces/default/pods/pod-nfs | jq -C
curl localhost:8001/api/v1/namespaces/default/pods/pod-nfs/proxy/

kubectl exec -it pod-nfs -- ls -l /usr/share/nginx/html
```

#### Ejemplo con NFS: aplicación Wordpress con MySQL

<!-- servicios:
- clusterip: solo en cluster
- nodeport: fuera de cluster
- loadbalancer: entorno cloud -->

1. Tweak NFS

```bash
# En 201 (NFS server)

sudo rmdir /var/datos
sudo mkdir -p /var/datos/wordpress
sudo mkdir -p /var/datos/mysql
sudo chmod o+rwx /var/datos

sudo sed -i '/\/var\/datos/d' /etc/exports
{
  echo '/var/datos/wordpress *(rw,sync,no_root_squash,no_all_squash)'
  echo '/var/datos/mysql *(rw,sync,no_root_squash,no_all_squash)'
} | sudo tee -a /etc/exports

sudo systemctl restart nfs-kernel-server

showmount -e
```

```bash
# En 101, 202-206
sudo umount -R /var/datos && sudo rmdir /var/datos
sudo mkdir -p /var/datos/wordpress && sudo mount -t nfs ns.cluster.net:/var/datos/wordpress /var/datos/wordpress
sudo mkdir -p /var/datos/mysql && sudo mount -t nfs ns.cluster.net:/var/datos/mysql /var/datos/mysql
df -h
```

2. Kubernetes

```bash
cd ~/k8s/nfs
nvim wordpress-mysql_pv-pvc-cm-svc-deploy.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-wordpress
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: wordpress
  nfs:
    path: /var/datos/wordpress
    server: ns.cluster.net                  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!?
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-mysql
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: mysql
  nfs:
    path: /var/datos/mysql
    server: ns.cluster.net
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-wordpress
spec:
  storageClassName: wordpress
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-mysql
spec:
  storageClassName: mysql
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: datos-wordpress-env
  namespace: default
data:
  WORDPRESS_DB_HOST: mysql
  WORDPRESS_DB_PASSWORD: password
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: NodePort
  # type: LoadBalancer
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate      # VS RollingUpdate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - name: wordpress
        image: wordpress:4.8-apache
        # env: {- name: foo value: bar}
        envFrom:
        - configMapRef:
            name: datos-wordpress-env
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
        # Ojo resources
        resources:
          requests:
            memory: "200Mi"
            cpu: "100m"
          limits:
            memory: "500Mi"
            cpu: "200m"
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: pvc-wordpress

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: datos-mysql-env
  namespace: default
data:
  MYSQL_ROOT_PASSWORD: password
  # El resto durante la instalación...
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None     # ...
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.6
        envFrom:
        - configMapRef:
            name: datos-mysql-env
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
        # Error OOMKilled si no se definen recursos
        resources:
          requests:
            memory: "500Mi"
            cpu: "100m"
          limits:
            memory: "1Gi"
            cpu: "200m"
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: pvc-mysql

```
```bash
kubectl apply -f wordpress-mysql_pv-pvc-cm-svc-deploy.yaml
kubectl get svc
kubectl get pods

xdg-open http://206.cluster.net:32195 || brave http://206.cluster.net:32195
  # Titulo=MIWEBSITE Usuario=wordpress-admin Pass=0eVwjvvC7)%mtKajoJ

sudo tree /var/datos
```

```txt
[~] kubectl get nodes -o wide                                                                                                                              16:52:21
NAME         STATUS   ROLES           AGE    VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE                           KERNEL-VERSION          CONTAINER-RUNTIME
101-arch     Ready    control-plane   5d6h   v1.29.2   192.168.10.101   <none>        Arch Linux                         6.7.9-arch1-1           containerd://1.7.13
201-ubuntu   Ready    <none>          5d6h   v1.29.2   192.168.1.35     <none>        Ubuntu 22.04.4 LTS                 5.15.0-100-generic      containerd://1.6.28
202-ubuntu   Ready    <none>          5d6h   v1.29.2   192.168.10.202   <none>        Ubuntu 22.04.4 LTS                 5.15.0-100-generic      containerd://1.6.28
203-ubuntu   Ready    <none>          5d6h   v1.29.2   192.168.10.203   <none>        Ubuntu 22.04.4 LTS                 5.15.0-100-generic      containerd://1.6.28
204-fedora   Ready    <none>          5d6h   v1.29.2   192.168.10.204   <none>        Fedora Linux 39 (Server Edition)   6.7.7-200.fc39.x86_64   containerd://1.6.28
205-fedora   Ready    <none>          5d6h   v1.29.2   192.168.10.205   <none>        Fedora Linux 39 (Server Edition)   6.7.7-200.fc39.x86_64   containerd://1.6.28
206-arch     Ready    <none>          5d6h   v1.29.2   192.168.10.206   <none>        Arch Linux                         6.7.9-arch1-1           containerd://1.7.13
[~]                                                                                                                                                        16:52:23
[~] kubectl get pods -o wide                                                                                                                               16:52:25
NAME                         READY   STATUS    RESTARTS      AGE   IP             NODE         NOMINATED NODE   READINESS GATES
mysql-5499b7d87f-2tltr       1/1     Running   0             17m   10.0.170.216   203-ubuntu   <none>           <none>
wordpress-68685cf997-td2gs   1/1     Running   1 (16m ago)   17m   10.0.151.160   206-arch     <none>           <none>
[~]                                                                                                                                                        16:52:28
[~]                                                                                                                                                        16:52:29
[~] kubectl get svc -o wide                                                                                                                                16:52:29
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE    SELECTOR
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        5d6h   <none>
mysql        ClusterIP   None            <none>        3306/TCP       36m    app=wordpress,tier=mysql
wordpress    NodePort    10.100.206.18   <none>        80:32195/TCP   36m    app=wordpress,tier=frontend
[~]                                                                                                                                                         16:53:08



──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
pabloqpacin@101-arch:~ » curl -v 192.168.10.206:32195
*   Trying 192.168.10.206:32195...
* Connected to 192.168.10.206 (192.168.10.206) port 32195
> GET / HTTP/1.1
> Host: 192.168.10.206:32195
> User-Agent: curl/8.6.0
> Accept: */*
>
< HTTP/1.1 302 Found
< Date: Mon, 18 Mar 2024 15:53:04 GMT
< Server: Apache/2.4.10 (Debian)
< X-Powered-By: PHP/5.6.32
< Expires: Wed, 11 Jan 1984 05:00:00 GMT
< Cache-Control: no-cache, must-revalidate, max-age=0
< Location: http://192.168.10.206:32195/wp-admin/install.php
< Content-Length: 0
< Content-Type: text/html; charset=UTF-8
<
* Connection #0 to host 192.168.10.206 left intact
pabloqpacin@101-arch:~ »
```

- Escalar WordPress

```bash
kubectl describe svc wordpress | grep 'Endpoints'

kubectl scale --replicas=4 deploy/wordpress
kubectl describe svc wordpress | grep 'Endpoints'
kubectl get deploy && kubectl get pods && kubectl get rs
kubectl scale --replicas=2 deploy/wordpress

kubectl describe deploy wordpress | grep -A7 'Events'
```
> MySQL no se podría escalar/distribuir sin más (habría que configurar cluster de mysql)

### 19. Storage Class -- almacenamiento dinámico

> - https://kubernetes.io/docs/concepts/storage/storage-classes/
> - Se recomienda integrar con **NFS**, y ojo con los *provisioners*

- Introducción
  - Kubernetes elige el pv...
  - ¡Importante provisioner (plugin) según plataforma!

...

- Crear sc, pv y pvc asociados

```bash
mkdir -p ~/k8s/sc && cd $_
nvim bbdd_sc-pv-pvc-pod.yaml
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    description: Esto es un ejemplo de Storage Class
  name: bbdd
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer     # según proveedor

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-bbdd-vol1
spec:
  storageClassName: bbdd
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/bbdd-vol1"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-bbdd-vol2
spec:
  storageClassName: bbdd
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/bbdd-vol2"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-bbdd
spec:
  storageClassName: bbdd
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi

---
apiVersion: v1
kind: Pod
metadata:
  name: postgres-db1
spec:
  containers:
  - name: postgres-db1
    image: postgres:16.2
    ports:
    - containerPort: 5432
      protocol: TCP
    volumeMounts:
    - mountPath: /var/lib/postgresql/data
      name: postgres-db-volume1
    env:
      - name: POSTGRES_PASSWORD
        value: "secret"
      - name: POSTGRES_USER
        value: "odoo"
      - name: POSTGRES_DB
        value: "postgres"
  volumes:
  - name: postgres-db-volume1
    persistentVolumeClaim:
      claimName: pvc-bbdd
 
```
```bash
kubectl apply -f bbdd_sc-pv-pvc-pod.yaml
# kubectl get pv && kubectl get pvc && kubectl get sc
# kubectl get pvc | grep 'Pending'      # if no pod assigned!!
kubectl get pv | grep 'pvc-bbdd'        # SE SELECCIONA DINÁMICAMENTE SEGÚN TAMAÑO
ssh 206.cluster.net && sudo ls -la /tmp/bbdd-vol2
```

- Laboratorio con SC dinámico

```bash
cd ~/k8s/sc
nvim dinamico_sc-pv-pvc.yaml
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sc-discos-locales
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: Immediate
reclaimPolicy: Delete

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: volume1
  labels:
    type: local
    curso: kubernetes
spec:
  storageClassName: sc-discos-locales
  capacity:
    storage: 4Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/datos"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: volume2
  labels:
    type: local
    curso: kubernetes
spec:
  storageClassName: sc-discos-locales
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/datos"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: volume3
  labels:
    type: local
    curso: kubernetes
spec:
  storageClassName: sc-discos-locales
  capacity:
    storage: 6Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/datos"

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dinamico
spec:
  storageClassName: sc-discos-locales
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```
```bash
kubectl apply -f dinamico_sc-pv-pvc .yaml
kubectl get pvc && kubectl get pv
```

- Generar PV automáticos

```bash
nvim automatico_sc-pvc.yaml
```
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sc-dinamica
provisioner: k8s.io/minikube-hostpah    # OJO!!
volumeBindingMode: Immediate
reclaimPolicy: Delete

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dinamico
spec:
  storageClassName: sc-dinamica
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```
```bash
kubectl apply -f automatico_sc-pvc.yaml
kubectl get pvc && kubectl get pv
kubectl describe pvc pvc-dinamico
```

#### Laboratorio: AWS y discos ESB

> https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html

- Instalar Driver CSI
- Crear volumen EBS, roles y políticas
- Crear PV, PVC


### 20. Otros Workloads -- más allá de los Deployments

- Workloads
  - Tipos
    - **Deployments**: stateless, relación con pods/rs...
    - **ReplicaSet**: asociados al Deployment
    - **StatefulSet**: soporte para aplicaciones con estado, alta disponibilidad, etc (eg. BD)
    - **DaemonSet**: útiles para entornos log o monitorización
    - Job y CronJob: de forma planificada para hacer backups, logs etc
    - **Custom Resource**: los anteriores, adaptados...

...

- **StatefulSets** (BD)
  - Control para ejecutar pods que se encargan de aplicaciones con estado
  - A los pods se les asigna una id concreta (no aleatoria como en los deploy) y secuencial
  - No son intercambiables: al borrar uno, no se crea uno nuevo/sustituto sino el mismo (misma config, datos etc)
  - Los pods no comparten datos: cada uno de ellos maneja su propio volumen persistente (pod > pvc > pv > nodo)
  - Replicación no en kubernetes sino en el software (ej MySQL maestro + MySQL esclavos)
  - Los PV se crean a partir de una StorageClass y un volumeClaim template, de forma exclusiva para cada pod
  - (Servicio headless) Cada pod tiene su propio DNS dentro del servicio

- Ejemplo con Mongo (almacenamiento dinámico con minikube...)

...

- DaemonSets
  - "Tantos pods como nodos"

> [logstash](https://www.elastic.co/es/logstash)

```bash
mkdir ~/k8s/otros && cd $_
nvim daemonset-logstash.yaml
```
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-daemonset
spec:
  selector:
    matchLabels:
      name: log
  template:
    metadata:
      labels:
        name: log
    spec:
      containers:
      - name: log
        image: logstash:8.12.2
```
```bash
kubectl apply -f daemonset-logstash.yaml
# Si creáramos un nuevo nodo, el DaemonSet crearía el pod correspondiente
```

- Jobs
  - Procesos individuales para tareas concretas, efímeros
  - CronJobs se pueden planificar

```bash
cd ~/k8s/otros
nvim job.yaml
```
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: job1
spec:
  template:
    spec:
      containers:
      - name: job1
        image: alpine
        command: ["sh","-c"]
        args: ["echo Estás en la máquina $(uname -n)"]
      restartPolicy: Never
```
```bash
kubectl apply -f job.yaml
kubectl logs <job-pod>
kubectl describe job job1
# Para actualizar el job, hay que eliminarlo
```

- Jobs con varias réplicas y otros parámetros...
  - eg. actualizar BD...

```bash
cd ~/k8s/otros
nvim job-varios.yaml
```
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: job2
spec:
  activeDeadlineSeconds: 15
  # completions: 3      # ojo
  # parallelism: 3      # ojo
  template:
    spec:
      containers:
      - name: job2
        image: alpine
        command: ["sh","-c"]
        args: ["echo Estás en la máquina $(uname -n)"]
      restartPolicy: Never
```
```bash
kubectl apply -f job-varios.yaml
```

- Cronjobs
  - `min - h - dm - m - dw`

```bash
cd ~/k8s/otros
nvim cronjob.yaml
```
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cron-job1
spec:
  schedule: "* * * * *"       # CADA MINUTO
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: job1
            image: alpine
            command: ["sh","-c"]
            args: ["echo Me ejecuto en este momento -- $(date)"]
          restartPolicy: Never
```
```bash
kubectl apply -f cronjob.yaml
```

### 21. Sondas -- PODS monitoring

- Introducción
  - liveness VS readiness
  - "Permiten realizar diagnósticos sobre los contenedores de kubernetes"
  - 3 tipos según tipo de prueba: comando VS http get VS socket
    - respuestas: success VS failure VS unknown
  - 3 tipos de comportamiento:
    - liveness: si el contenedor vive; si no, se elimina; ojo `RestartPolicy`
    - readiness: si la app funciona dentro del contenedor; 
    - startup: avisa de que el contenedor/app arranquen (útil antes de las otras dos)

...

- Sonda Liveness de tipo Command

```bash
mkdir ~/k8s/sondas && cd $_
nvim sonda-liveness.yaml
```
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: sonda-liveness
spec:
  containers:
  - name: pod-liveness
    image: ubuntu
    args:
    - /bin/sh
    - -c
    - mkdir /tmp/prueba; sleep 30; rm -rf /tmp/prueba; sleep 600
    livenessProbe:
      exec:
        command:
        - ls
        - /tmp/prueba
      initialDelaySeconds: 5
      periodSeconds: 5
```
```bash
kubectl apply -f sonda-liveness.yaml
kubectl describe pod sonda-liveness
```

- Sonda Liveness de tipo HTTP

> - OJO: [Custom Docker Image](https://hub.docker.com/repository/docker/pabloqpacin/sonda-web/general) (web + `sonda.html`)
> - OJO: Si usáramos volúmenes persistentes cambiaría el cuento...

```bash
cd ~/k8s/sondas
nvim sonda-http.yaml
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-d
spec:
  selector:
    matchLabels:
      app: web
  replicas: 1
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: apache
        image: pabloqpacin/sonda-web:v1
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /sonda.html
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  labels:
     app: web
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30002
    protocol: TCP
  selector:
     app: web
```
```bash
kubectl apply -f sonda-http.yaml

# kubectl get deploy && kubectl get pods && kubectl get rs && kubectl get svc
# curl localhost:30002

kubectl describe pod <pod> | grep 'Liveness'
kubectl exec -it <pod> -- bash
  # ls -la htdocs
  # rm htdocs/sonda.html

kubectl describe pod <pod> | grep -C5 'probe failed'
# RESTART HAPPENS
```

- Sonda Readiness de tipo Socket

**...**


### 22. RBAC -- Seguridad en clusters

> - https://kubernetes.io/docs/tasks/administer-cluster/certificates/
> - https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/

<!-- - https://dev-k8sref-io.web.app/docs/authentication/certificatesigningrequest-v1/
- https://cert-manager.io/docs/usage/kube-csr/ -->



- RBCA
  - No existe API específica para gestińo de usuarios (se hace de forma externa)
  - Opciones: **certificados** VS tokens VS basic auth VS oauth2
  - Flow: CLIENTES (usuarios, serviceaccounts) > RECURSOS (pods, secrets, nodes, pv, services, cm, ingress) > VERBOS-OPERACIONES (list, create, watch, get, delete, patch)
  - Estructura: *Roles* (get, create, ...) para objetos (pods, etc) en *namespace*; ClusterRoles (accesos a nodos,etc); asignación mediante **RoleBinding** entre cliente y los roles
  - Roles: acumulativos (si se dan, se tienen)

...

- Ver Roles a nivel de Namespace

```bash
kubectl create namespace ventas &&
kubectl get ns | grep 'ventas'

# kubectl config set-context --current --namespace=ventas

kubectl get roles --all-namespaces
kubectl describe role kube-proxy -n kube-system
kubectl describe role system:controller:cloud-provider -n kube-system

kubectl api-resources | grep 'role'
```

- Crear roles

```bash
mkdir ~/k8s/rbac && cd $_
nvim crear-role.yaml
```
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ventas       # IMPORTANTE
  name: operador
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
```
```bash
kubectl apply -f crear-role.yaml

kubectl get roles -n ventas
kubectl describe role operador -n ventas
```

- Cluster roles

```bash
kubectl get clusterroles
kubectl describe clusterrole system:node

cd ~/k8s/rbac
nvim crear-clusterrole.yaml

```
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: desarrollo
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "watch", "list"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "watch", "list", "get", "edit"]

```
```bash
kubectl apply -f crear-clusterrole.yaml

kubectl get clusterroles | grep 'desarrollo'
kubectl describe clusterrole desarrollo
```

- **Certificados** para el acceso de un usuario (P1)

```bash
mkdir ~/k8s-certs && cd $_

openssl genrsa -out desa1.key 4096
# ls desa1.key      # CLAVE PRIVADA

nvim desa1.csr.conf
# añadimos '[ req_ext ]'
```
```ini
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
O = desarrollo
CN = desa1

[ req_ext ]

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
```
```bash
openssl req -config desa1.csr.conf -new -key desa1.key -out desa1.csr
for file in $(ls); do cat $file; done

nvim solicitud.bash
# cambiamos 'certificates.k8s.io/v1beta1' por 'certificates.k8s.io/v1'
# añadimos 'spec.signerName: kubernetes.io/kube-apiserver-client' frente a error
# eliminamos '- server auth'
```
```bash
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: desa1-req-auth
spec:
  signerName: kubernetes.io/kube-apiserver-client
  groups:
  - system:authenticated
  request: $(cat desa1.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - client auth
EOF
```
```bash
bash solicitud.bash

kubectl get csr         # 'Pending'
kubectl certificate approve desa1-req-auth
kubectl get csr         # 'Approved,Issued'
kubectl get csr -o yaml

kubectl get csr desa1-req-auth -o jsonpath='{.status.certificate}' | base64 --decode > desa1.crt
# cat desa1.crt
```

- **Certificados** para el acceso de un usuario (P2)

> Se recomienda crear usuarios Linux

```bash
# kc config get-contexts

mkdir ~/k8s-certs/.kube
cp ~/.kube/config ~/k8s-certs/.kube/config

# sudo bat /etc/kubernetes/admin.conf
cd ~/k8s-certs && nvim .kube/config
# la parte 'clusters' queda igual
# en 'context' cambiamos el usuario, nombre, y actualizaremos 'current-context'
sed -i 's/user: kubernetes-admin/user: desa1/' ~/k8s-certs/.kube/config
sed -i 's/name: kubernetes-admin@kubernetes/name: desa1-context/' ~/k8s-certs/.kube/config
sed -i 's/current-context: kubernetes-admin@kubernetes/current-context: desa1-context/' ~/k8s-certs/.kube/config
sed -i 's/- name: kubernetes-admin/- name: desa1/' ~/k8s-certs/.kube/config
# en 'users', cambiamos el nombre y para los certificados ponemos los path...
sed -i "s#client-certificate-data:.*#client-certificate-data: $HOME/k8s-certs/desa1.crt#" ~/k8s-certs/.kube/config
sed -i "s#client-key-data:.*#client-key-data: $HOME/k8s-certs/desa1.key#" ~/k8s-certs/.kube/config
```
```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJR0c2U3F5QnZHek13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBek1UTXdPVEE0TlROYUZ3MHpOREF6TVRFd09URXpOVE5hTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURYUXJaRHpnVXQ4RThtUFhEWisxcjNsRk5EQk5tUVVZbU5KdG1QNU1YU1Q2TUdYNzhIaDFGVUJSUlcKZDFOSWZqdW5FZVlkTVA2Y0NNb3NYclJBR0pMamN3OWxjQUZYd2JQOVZNdkZqbTFGN1VSRnlHS3dLakZtS3JUbQp6OEw2SnJwdVY0V0dBb25Vc1MxdDAxNGFVWFBsTDFDM1RRNWhzVGtjR2g1WVNCTEtMYS9EQlhUcnNXM2RjT0tQCk45VmRWeGt6K0ZicjdpNGlsaWJrRmVIcFQzL1BUZXF2NUlLQ29PZ1FPMXFxc0J4aGFZbFNHTlN0b3lEa2tubXMKSm5vcDhTUFJyVUJnOVNQLzM3WTRvZWsxTmlISHZpSXA4UXF0T0Z2b2gwS2VyWTFXck8wTit6UlB2OWFWU2lHTwphZUpLZi9DczlvR2hwZTJQSng2S05IUXpWUzFsQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTaHZjc1AwTDZsdlowYlZrWk51ZkdmVE1yTUJUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQVdiajBtOEYyRwpNcENpQlJiR08rSVlVNWI3QlVtUXViN3VWS0tTaEU3S2xOcUp2a0RhQ2FZRHRVTXFFNVNpdTUwemdiWnFtZjdnCmxSS2ZBaWE3aXFJS25PKzhVU0RGSU1MYStSYjdXalRYYnpmMW5hZDc4Ry9wM2cxcTg0TVBCNVYxb3NZV0p2VHgKRFdkM0JrcWpMa2pHTStBZ3ZwMWZGeHE1Z1RDdnVvZFEvemZNT21RSTlDakJ1a1gwTW5NeWthNTJ4ZVNBRVErdwoyNmp0TWpJMXJSdXhXSmw4T3hER3RQQUpYZ01EbWMrQzV5aythREhBWUZQZnJPSmNuRnN0K29zNHNLTnZQeGtYClJoTk5vaW5MSFg3Z2VZMTZUS2RCM21xajk3anhocEswZi92YlVXQWpOSEFBbkVaQ1dPSzdmaSsxdVdid1RwaDAKczE3WlRpNjhwdFFhCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://192.168.10.101:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    # namespace: ventas
    user: desa1
  name: desa1-context
current-context: desa1-context
kind: Config
preferences: {}
users:
- name: desa1
  user:
    client-certificate-data: /home/pabloqpacin/k8s-certs/desa1.crt
    client-key-data: /home/pabloqpacin/k8s-certs/desa1.key
```
```bash
kubectl --kubeconfig=$HOME/k8s-certs/.kube/config get pods
```

- problemas...
    - https://github.com/openssl/openssl/issues/3536
    - https://superuser.com/questions/512673/openssl-how-to-create-a-certificate-with-an-empty-subject-dn/944378#944378
    - https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatessigningrequest


---

```bash
```
```yaml
```
```bash
```

---

### 23. Ingress -- conectar servicios al exterior

- Documentación
  - https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
  - https://kubernetes.github.io/ingress-nginx/deploy/

> **New Lab**: @setenova's POC_CICD_W1 on PaaS's K8s

- Acceso al cluster (FCOS) desde mi workstation

```bash
tsh login --proxy=foo.setenova.es:443 --user=pquevedo
tsh kube login poc-k8s-argocd
tsh proxy kube -p 8443
export KUBECONFIG=/home/pabloqpacin/.tsh/keys/foo.setenova.es/pquevedo-kube/foo.setenova.es/localproxy-8443-kubeconfig
```

- Instalar

```bash
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.2/deploy/static/provider/baremetal/deploy.yaml

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

<details>

> READ THIS SHI

```log
The ingress-nginx controller has been installed.
It may take a few minutes for the load balancer IP to be available.
You can watch the status by running 'kubectl get service --namespace ingress-nginx ingress-nginx-controller --output wide --watch'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

</details>

```log
pabloqpacin@Pop76:~ » kubectl -n ingress-nginx get all

NAME                                            READY   STATUS    RESTARTS   AGE
pod/ingress-nginx-controller-74d59b4b45-dn895   1/1     Running   0          99s

NAME                                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.254.111.136   <pending>     80:31998/TCP,443:32353/TCP   99s
service/ingress-nginx-controller-admission   ClusterIP      10.254.105.59    <none>        443/TCP                      99s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           99s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-74d59b4b45   1         1         1       100s
```

- Ejemplos de objeto Ingress (ojo `spec: defaultBackend`, ojo tema PATHs...)

```yaml
---
# ingress-example-1.yaml
apiVersion: networking.k8s.io/v
kind: Ingress
metadata:
  name: ingress-apache
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - http:
    paths:
    - path: /testpath
    pathType: Prefix
    backend:
      service:
        name: tset
        port:
          number: 80

---
# ingress-example-2.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wildcard-host
spec:
  rules:
  - host: "foo.bar.com"
    http:
      paths:
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: service1
            port:
              number: 80
  - host: "*.foo.com"
    http:
      paths:
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: service2
            port:
              number: 80

---
# 1-host-n-servicios.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-fanout-example
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        pathType: Prefix
        backend:
          service:
            name: service1
            port:
              number: 4200
      - path: /bar
        pathType: Prefix
        backend:
          service:
            name: service2
            port:
              number: 8080

---
# n-hosts.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: name-virtual-host-ingress
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: service1
            port:
              number: 80
  - host: bar.foo.com
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: service2
            port:
              number: 80
```

- Crear app (deploy + svc)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-d
spec:
  selector:
    matchLabels:
      app: web
  replicas: 1
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: apache
        image: pabloqpacin/sonda-web:v1
        ports:
        - containerPort: 80
        # livenessProbe:
        #   httpGet:
        #     path: /sonda.html
        #     port: 80
        #   initialDelaySeconds: 3
        #   periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-a
  labels:
     app: web
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30002
    protocol: TCP
  selector:
     app: web
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-b
  labels:
     app: web
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30003
    protocol: TCP
  selector:
     app: web
```
```yaml
# ingress2.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-apache
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx   # OJO
  rules:
    # DNS apunta al cluster (ie. DNS > HAProxy > K8s host > Ingress)
  - host: argocd.setenova.es
    http:
      paths:
      - path: /apache
        pathType: Exact
        backend:
          service:
            name: web-svc
            port:
              number: 80
      # - path: /nginx
      #   pathType: Exact
      #   backend:
      #     service:
      #       name: foo
      #       port:
      #         number: 80

```
```bash
nvim deploy_svc.yaml
  # ...

kubectl apply -f deploy_svc.yaml

{
  NODE_IP=$(kubectl --namespace default get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
  curl ${NODE_IP}:30002
    # BUENARDAS
}

# ---

kubectl get ingressclasses

nvim ingress2.yaml
  # ...

kubectl apply -f deploy_svc.yaml

# ---

# config. HAProxy
    # server k8s-ingress-nginx 172.26.10.20:80/apache check
```

- Varios hosts!!


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-d
spec:
  selector:
    matchLabels:
      app: web
  replicas: 1
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: apache
        image: pabloqpacin/sonda-web:v1
        ports:
        - containerPort: 80
        # livenessProbe:
        #   httpGet:
        #     path: /sonda.html
        #     port: 80
        #   initialDelaySeconds: 3
        #   periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-a
  labels:
     app: web
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30002
    protocol: TCP
  selector:
     app: web
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc-b
  labels:
     app: web
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30003
    protocol: TCP
  selector:
     app: web
```
```yaml
# ingress2.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-multihost
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx   # OJO
  rules:
    # DNS apunta al cluster (ie. DNS > HAProxy > K8s host > Ingress)
  - host: argocd.setenova.es
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc-a
            port:
              number: 80
  - host: harbor.setenova.es
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-svc-b
            port:
              number: 80
```

> ËXITOS


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
