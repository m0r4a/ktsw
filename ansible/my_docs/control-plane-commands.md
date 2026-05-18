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

3. Install necesary kernel module and some utils

```bash
sudo dnf install -y kernel-modules-extra git bash-completion
```

**A restart is needed I THINK, I restarted and worked**

5. Load kernel modues

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

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

1. Install k3s

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --flannel-backend=none --disable=servicelb --disable-network-policy --cluster-cidr=11.0.0.0/16 --service-cidr=11.1.0.0/16" sh -
```

2. Configure the `kubectl`

```bash
mkdir -p ~/.kube && sudo install -o 1000 -g 1000 -m 600 /etc/rancher/k3s/k3s.yaml ~/.kube/config && echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc && source ~/.bashrc
```

3. Install Cilium CLI

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

4. Install helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
```

5. Install cilium

5.1 Using HELM

```bash
helm install cilium oci://quay.io/cilium/charts/cilium --version 1.19.1 --namespace kube-system -f https://raw.githubusercontent.com/m0r4a/flux_cd_testing/refs/heads/main/apps/infrastructure/cilium/values.yaml --set k8sServiceHost=<control-plane-ip> --set k8sServicePort=6443
```

5.1 Using Cilium CLI (deprecated)

Install cilium itself (deprecated)

```bash
cilium install --version 1.19.0 --set ipam.operator.clusterPoolIPv4PodCIDRList=11.0.0.0/16
```

Enable hubble (deprecated)

```bash
cilium hubble enable --ui
```

7. Install Hubble Client

```bash
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/main/stable.txt)
HUBBLE_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
```

## Kubectl aliases & QOL tools

1. Create `.bash_profile` to ensure `.bashrc` loads on SSH login
```bash
cat > ~/.bash_profile <<'EOF'
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF
```

2. Install kubectl-aliases
```bash
curl -sL https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases -o ~/.kubectl_aliases
```

3. Enable kubectl bash completion + aliases
```bash
cat >> ~/.bashrc <<'EOF'
# kubectl completion
if command -v kubectl &>/dev/null; then
  source <(kubectl completion bash)
fi
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
```

6. Apply changes
```bash
source ~/.bashrc
```

## Flux cd

1. Install the cli

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
```
3. Source the config:

```bash
qsource /etc/profile.d/bash_completion.sh
```

4. And make it persist
```bash
echo ". <(flux completion bash)" >> ~/.bashrc
```

## Token for the workers

1. Get the token:

```bash
sudo cat /var/lib/rancher/k3s/server/node-token
```
