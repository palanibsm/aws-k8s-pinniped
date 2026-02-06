[control_plane]
${control_plane_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${replace(ssh_key_path, ".pub", "")}

[workers]
%{ for ip in worker_ips ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=${replace(ssh_key_path, ".pub", "")}
%{ endfor ~}

[k8s_cluster:children]
control_plane
workers

[k8s_cluster:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'