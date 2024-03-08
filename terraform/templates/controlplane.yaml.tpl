machine:
  nodeLabels:
    node.cloudprovider.kubernetes.io/platform: proxmox
    topology.kubernetes.io/region: ${px_region}
    topology.kubernetes.io/zone: ${px_node}
  certSANs:
    - ${apiDomain}
    - ${ipv4_vip}
    - ${ipv4_local}
  kubelet:
    defaultRuntimeSeccompProfileEnabled: true # Enable container runtime default Seccomp profile.
    disableManifestsDirectory: true # The `disableManifestsDirectory` field configures the kubelet to get static pod manifests from the /etc/kubernetes/manifests directory.
    extraArgs:
      cloud-provider: external
      rotate-server-certificates: true
    clusterDNS:
      - 169.254.2.53
      - ${cidrhost(split(",",serviceSubnets)[0], 10)}
  network:
    hostname: "${hostname}"
    interfaces:
      - interface: eth0
        addresses:
          - ${ipv4_local}/24
        vip:
          ip: ${ipv4_vip}    
      - interface: dummy0
        addresses:
          - 169.254.2.53/32
    extraHostEntries:
      - ip: 127.0.0.1
        aliases:
          - ${apiDomain} 
    nameservers:
      - 1.1.1.1
      - 8.8.8.8
    kubespan:
      enabled: false
  install:
    disk: /dev/sda
    image: ghcr.io/siderolabs/installer:${talos-version}
    bootloader: true
    wipe: false
  sysctls:
    net.core.somaxconn: 65535
    net.core.netdev_max_backlog: 4096
  systemDiskEncryption:
    state:
      provider: luks2
      options:
        - no_read_workqueue
        - no_write_workqueue
      keys:
        - nodeID: {}
          slot: 0
    ephemeral:
      provider: luks2
      options:
        - no_read_workqueue
        - no_write_workqueue
      keys:
        - nodeID: {}
          slot: 0
  time:
    servers:
      - time.cloudflare.com
  # Features describe individual Talos features that can be switched on or off.
  features:
    rbac: true # Enable role-based access control (RBAC).
    stableHostname: true # Enable stable default hostname.
    apidCheckExtKeyUsage: true # Enable checks for extended key usage of client certificates in apid.
    kubernetesTalosAPIAccess:
      enabled: true
      allowedRoles:
        - os:reader
      allowedKubernetesNamespaces:
        - kube-system
        - default
  kernel:
    modules:
      - name: br_netfilter
        parameters:
          - nf_conntrack_max=131072
  registries:
    mirrors:
      docker.io:
        endpoints:
          - http://${registry-endpoint}:80/v2/proxy-docker.io
        overridePath: true
      ghcr.io:
        endpoints:
          - http://${registry-endpoint}:80/v2/proxy-ghcr.io
        overridePath: true
      gcr.io:
        endpoints:
          - http://${registry-endpoint}:80/v2/proxy-gcr.io
        overridePath: true
      registry.k8s.io:
        endpoints:
          - http://${registry-endpoint}:80/v2/proxy-registry.k8s.io
        overridePath: true
      quay.io:
        endpoints:
          - http://${registry-endpoint}:80/v2/proxy-quay.io
        overridePath: true
cluster:
  controlPlane:
    endpoint: https://${apiDomain}:6443
  network:
    dnsDomain: ${domain}
    podSubnets: ${format("%#v",split(",",podSubnets))}
    serviceSubnets: ${format("%#v",split(",",serviceSubnets))}
    cni:
      name: custom
      urls:
        - https://raw.githubusercontent.com/Randsw/proxmox-capi-talos/main/manifests/cilium.yaml
  proxy:
    disabled: true
  etcd:
    extraArgs:
      listen-metrics-urls: http://0.0.0.0:2381
  inlineManifests:
  - name: fluxcd # Flux CD namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: flux-system
          labels:
            app.kubernetes.io/instance: flux-system
            app.kubernetes.io/part-of: flux
            pod-security.kubernetes.io/warn: restricted
            pod-security.kubernetes.io/warn-version: latest
  - name: cilium # Cilium namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: cilium
          labels:
            pod-security.kubernetes.io/enforce: "privileged"
  - name: d8-system # ??? namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: d8-system
          labels:
            pod-security.kubernetes.io/enforce: "privileged"
  - name: external-dns # External dns namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: external-dns
  - name: kasten # Kasten namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: kasten-io
  - name: cert-manager # Cert-manager namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: cert-manager
  - name: ingress-nginx # Ingress-nginx namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: ingress-nginx
  - name: csi-proxmox # csi-proxmox namespace
    contents: |- 
      apiVersion: v1
      kind: Namespace
      metadata:
          name: csi-proxmox
  - name: flux-system-secret # SSH credential to auth in Git # TODO Change to token auth
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: github-creds
        namespace: flux-system
      data:
        identity: ${base64encode(identity)}
        identity.pub: ${base64encode(identitypub)}
        known_hosts: ${base64encode(knownhosts)}
  - name: proxmox-cloud-controller-manager # Proxmox cloud controller manager secret to access Proxmox API (Label nodes, set nodes region and cluster to support affinity etc. Add IP adress to Node yaml description)
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: proxmox-cloud-controller-manager
        namespace: kube-system
      data:
        config.yaml: ${base64encode(clusters)}
  - name: proxmox-csi-plugin # Proxmox csi plugin secret to access Proxmox API()
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: proxmox-csi-plugin
        namespace: csi-proxmox
      data:
        config.yaml: ${base64encode(clusters)}
  - name: proxmox-operator-creds # Proxmox operator secret to access Proxmox API(Create VM from YAML)
    contents: |-
      apiVersion: v1
      kind: Secret
      type: Opaque
      metadata:
        name: proxmox-operator-creds
        namespace: kube-system
      data:
        config.yaml: ${base64encode(pxcreds)}
  - name: metallb-addresspool # Metallb ip adresspool
    contents: |- 
      apiVersion: metallb.io/v1beta1
      kind: IPAddressPool
      metadata:
        name: first-pool
        namespace: metallb-system
      spec:
        addresses:
        - ${metallb_l2_addressrange}
  - name: metallb-l2 # L2 ip adresspool Advertisement
    contents: |- 
      apiVersion: metallb.io/v1beta1
      kind: L2Advertisement
      metadata:
        name: layer2
        namespace: metallb-system
      spec:
        ipAddressPools:
        - first-pool
  - name: flux-vars # ???? cluster config map ??????
    contents: |- 
      apiVersion: v1
      kind: ConfigMap
      metadata:
        namespace: flux-system
        name: cluster-settings
      data:
        SIDERO_ENDPOINT: ${sidero-endpoint}
        STORAGE_CLASS: ${storageclass}
        STORAGE_CLASS_XFS: ${storageclass-xfs}
        CLUSTER_0_VIP: ${cluster-0-vip} 
  externalCloudProvider:
    enabled: true
    manifests:
    - https://raw.githubusercontent.com/randsw/proxmox-capi-talos/main/manifests/coredns-local.yaml        #Kubernetes DNS system
    - https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml       #MetalLB deploy
    - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml           #Deploy metrics server
    - https://github.com/fluxcd/flux2/releases/latest/download/install.yaml                                #FluxCD deploy
    - https://raw.githubusercontent.com/randsw/proxmox-capi-talos/main/manifests/fluxcd-kustomization.yaml #FluxCD kustomization and initialize GitReposytory with manifest to sync
    - https://raw.githubusercontent.com/siderolabs/talos-cloud-controller-manager/main/docs/deploy/cloud-controller-manager.yml # Deploy Talos Cloud-controller 
    - https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/main/docs/deploy/cloud-controller-manager-talos.yml # Deploy Proxmox Cloud-controller 
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml # Prometheus operator CRDs
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
    - https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml