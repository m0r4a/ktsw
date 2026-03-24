## Prepare rocky linux

1. Update the system

```bash
sudo dnf update -y
```

2. Disable swap

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

3. Install necesary kernel module

```bash
sudo dnf install -y kernel-modules-extra
```

5. Load kernel modues

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

**A restart is needed I THINK, I restarted and worked**

6. Make them persist

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

5. Do fun stuff with systemd

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

## K3s stuff

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://k3s.example.com --token mypassword" sh -s -
```

For example:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://10.0.0.10:6443 --token K105559e49e0323a046eb9dd29edf604fd6b88a3026158fa9c2ad3917ba146f5c0b::server:4a60fdc2da09a246563ea577f69e5f46" sh -s -
```
