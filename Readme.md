# Kubernetes as a Service with Proxmox and Cluster API on Talos Linux

Inspired by [Kubernetes As a Service (KAAS) in Proxmox](https://github.com/kubebn/talos-proxmox-kaas)

An attempt to adapt this solution to the air-gapped architecture.

All the necessary images are stored in the Harbor, which is located in the inner contour.

## Packer command

Prepare infrastructure for Packer

### 1. Create VM for Proxmox

   1.1 Virtualbox network setup details
   Set network interface type - `bridged network`
   Set network interface promiscuous mode - `Allow all`

### 2. Make WIFI dongle name predictable

   Copy rule file:

   ```shell
   sudo cp /lib/udev/rules.d/80-net-setup-link.rules /etc/udev/rules.d/
   ```

   Change variable in file - `$env{ID_NET_NAME}` to `$env{ID_NET_SLOT}`

### 3. Setup port-forward from Wifi to Ethernet

<https://unix.stackexchange.com/questions/565742/share-the-wifi-connection-to-the-wired-interface-in-cli>
    Suppose that enp1s0 is LAN Ethernet interface and usb0 is USB WIFI modem

```shell
    #ENABLE PACKET FORWARD
    echo 1 > /proc/sys/net/ipv4/ip_forward
```

```shell
    #ENABLE FORWARD Packet beetwen Wired LAN and WIFI dongle
    sudo iptables -A FORWARD -i enp1s0 -o usb0 -j ACCEPT
    sudo iptables -A FORWARD -i usb0 -o enp1s0 -j ACCEPT
    sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
```

### 4. Build Talos Linux image with Packer

Run Packer command:

```shell
packer build -only=develop.proxmox-iso.talos -var-file="local.pkrvars.hcl" -var-file="credential.pkrvars.hcl" .
```

### 5. Build Harbor container registry image based on Ubuntu 22.04 with Packer (Optional)

Run Packer command:

```shell
packer build -only=develop.proxmox-iso.harbor-ubuntu-jammy -var-file="local.pkrvars.hcl" -var-file="credential.pkrvars.hcl" .
```

### 6. Deploy Harbor container registry on Proxmox (Optional)

Run Terraform command:

```shell
cd harbor/
terraform apply -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"
```

### 7. Deploy Kaas on Proxmox

Run Terraform command:

```shell
terraform apply -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"
```

### 8. Access to management cluster

After `terraform apply` is finished, try to execute: ``` kubectl get nodes```
If all proceed as planned you see output

```bash
NAME              STATUS   ROLES           AGE    VERSION
control-plane-0   Ready    control-plane   153m   v1.27.2
control-plane-1   Ready    control-plane   153m   v1.27.2
control-plane-2   Ready    control-plane   153m   v1.27.2
worker-0          Ready    <none>          153m   v1.27.2
worker-1          Ready    <none>          153m   v1.27.2
worker-2          Ready    <none>          153m   v1.27.2

```

### 9. Provision workload cluster

In Proxmox you can see 5 new VMs - they present two clusters:

- cluster-0 (sidero-master-1, sidero-worker-1)
- cluster-flux (sidero-control-plane-flux-1, sidero-worker-flux-1,sidero-worker-flux-1, sidero-worker-flux-1)

Cluster-0 is simple cluster with preinstalled metallb and cilium

Cluster-flux is a more complex cluster with metallb, cillium and flux.

#### 9.1 Cluster-0

Check server and serverclasses:

```bash
kubectl get servers,serverclasses
```

In ServerClasses for [masters](kubernetes/infra/clusters/cluster-0/manifests/cp-dev-sc.yaml) and [workers](kubernetes/infra/clusters/cluster-0/manifests/worker-dev-sc.yaml) you can find `selector` that we need to apply to the servers.

Connection between server name and vms you can find in vm [definition](kubernetes/infra/clusters/cluster-0/manifests/vms.yaml) in smbios1 section. This uuid is match to server name in kubernetes.

So we need to label server to connect then to serverclasses:

```bash
kubectl label server <master-server> master-dev=true
kubectl label server <worker-server> worker-dev=true
```

Check that both server in use:

```bash
kubectl get serverclasses
```

:warning: Remember server `qualifiers` and `labels` must exactly match serverclasses `qualifiers` and `labelselector`

`Qualifiers` depends on Proxmox version!

Now we fetch talosconfig and kubeconfig from the cluster:

Find talosconfig name:

```bash
kubectl get talosconfigs
```

Find the one that start with `cluster-0-cp`

```bash
kubectl get talosconfig -o yaml <name you find in previous step> -o jsonpath='{.status.talosConfig}' > cluster-0.yaml

talosctl --talosconfig cluster-0.yaml kubeconfig --force -n <cluster-0-vip> -e <cluster-0-vip>
```

`cluster-0-vip` you define in terraform vars

Change the API endpoint to the Talos cluster VIP `cluster-0-vip`

```bash
kubectl --kubeconfig ~/.kube/config config set clusters.cluster-0.server https://<cluster-0-vip>:6443

Property "clusters.cluster-0.server" set.
```

At that point, we have a fully working cluster bootstrapped and provisioned via Sidero and FluxCD:

```bash
NAME            STATUS   ROLES           AGE    VERSION
talos-5an-fry   Ready    <none>          166m   v1.27.1
talos-u5z-t1k   Ready    control-plane   166m   v1.27.1
```

#### 9.2 Cluster-flux
This cluster demostrate how we can provide workload cluster with FluxCD like our management cluster. All step similar to `cluster-0`, except FluxCD configuration.

Lets start.

Check server and serverclasses:

```bash
kubectl get servers,serverclasses
```

In ServerClasses for [control-planes](kubernetes/infra/clusters/cluster-flux/manifests/cp-flux-sc.yaml) and [workers](kubernetes/infra/clusters/cluster-flux/manifests/worker-flux-sc.yaml) you can find `selector` that we need to apply to the servers.

Connection between server name and vms you can find in vm [definition](kubernetes/infra/clusters/cluster-flux/manifests/vms.yaml) in smbios1 section. This uuid is match to server name in kubernetes.

So we need to label server to connect then to serverclasses:

```bash
kubectl label server <control-plane-server> cp-dev=true
kubectl label server <worker-server-1> <worker-server-2> <worker-server-3> worker-flux=true
```

Check that both server in use:

```bash
kubectl get serverclasses
```

:warning: Remember server `qualifiers` and `labels` must exactly match serverclasses `qualifiers` and `labelselector`

`Qualifiers` depends on Proxmox version!

Now we fetch talosconfig and kubeconfig from the cluster:

Find talosconfig name:

```bash
kubectl get talosconfigs
```

Find the one that start with `cluster-flux-cp`

```bash
kubectl get talosconfig -o yaml <name you find in previous step> -o jsonpath='{.status.talosConfig}' > cluster-flux.yaml

talosctl --talosconfig cluster-flux.yaml kubeconfig --force -n <cluster-flux-vip> -e <cluster-flux-vip>
```

`cluster-flux-vip` you define in terraform vars

Change the API endpoint to the Talos cluster VIP `cluster-flux-vip`

```bash
kubectl --kubeconfig ~/.kube/config config set clusters.cluster-flux.server https://<cluster-flux-vip>:6443

Property "clusters.cluster-flux.server" set.
```

At that point, we have a fully working cluster bootstrapped and provisioned via Sidero and FluxCD:

```bash
NAME            STATUS   ROLES           AGE    VERSION
talos-74x-bhn   Ready    control-plane   165m   v1.27.1
talos-8sb-xrn   Ready    <none>          165m   v1.27.1
talos-lj1-spz   Ready    <none>          165m   v1.27.1
talos-uk8-85j   Ready    <none>          165m   v1.27.1
```

The last thing we need is to provide credentials for FluxCD to access to our git repository with config. There are several ways

In this example i just copy secret from management cluster to workload cluster because configuration for workload cluster live in same github repository

```bash
kubectl get secret github-creds -oyaml > github-creds.yaml
```

```bash
kubectl config use context admin@cluster-flux
```

```bash
kubeclt apply -f github-creds.yaml
```

Other way is to add secret in workload cluster Talos bootstrap config using `inlinemanifests` with postsubstitute from secret from management cluster.

#### 4. Cleanup

Delete all qemu CR in management cluster:

```bash
kubectl delete --all qemu
```

Delete Terraform resources

```bash
terraform destroy -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"
```
