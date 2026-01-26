[control-plane]
%{ for name, node in nodes ~}
%{ if node.role == "control-plane" ~}
${node.ip} ansible_user=${node.user}
%{ endif ~}
%{ endfor ~}

[worker]
%{ for name, node in nodes ~}
%{ if node.role == "worker" ~}
${node.ip} ansible_user=${node.user}
%{ endif ~}
%{ endfor ~}

[all:vars]
ansible_ssh_private_key_file=${ssh_private_key_path}
