# Kubernetes as a Service with Proxmox and Cluster API on Talos Linux

Inspired by [Kubernetes As a Service (KAAS) in Proxmox](https://github.com/kubebn/talos-proxmox-kaas)

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
    `packer build -only=develop.proxmox-iso.talos -var-file="local.pkrvars.hcl" -var-file="credential.pkrvars.hcl" .`

### 5. Build Harbor container registry image based on Ubuntu 22.04 with Packer (Optional)

Run Packer command:
    `packer build -only=develop.proxmox-iso.harbor-ubuntu-jammy -var-file="local.pkrvars.hcl" -var-file="credential.pkrvars.hcl" .`

### 6. Deploy Harbor container registry on Proxmox (Optional)

Run Terraform command:

```shell
    cd harbor/
    terraform apply -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"
```

### 6. Deploy Kaas on Proxmox

Run Terraform command:

```shell
    terraform apply -auto-approve -var-file="credential.tfvars" -var-file="terraform.tfvars"
```
