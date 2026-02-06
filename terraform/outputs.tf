# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# Control Plane Outputs
output "control_plane_public_ip" {
  description = "Control plane public IP"
  value       = aws_instance.control_plane.public_ip
}

output "control_plane_private_ip" {
  description = "Control plane private IP"
  value       = aws_instance.control_plane.private_ip
}

# Worker Node Outputs
output "worker_public_ips" {
  description = "Worker nodes public IPs"
  value       = aws_instance.worker[*].public_ip
}

output "worker_private_ips" {
  description = "Worker nodes private IPs"
  value       = aws_instance.worker[*].private_ip
}

# Load Balancer Outputs
output "nlb_dns_name" {
  description = "NLB DNS name for Kubernetes API server"
  value       = aws_lb.k8s_api.dns_name
}

output "nlb_endpoint" {
  description = "Full NLB endpoint with port"
  value       = "${aws_lb.k8s_api.dns_name}:6443"
}

# Ansible Inventory Output
output "ansible_inventory" {
  description = "Ansible inventory content"
  value = templatefile("${path.module}/inventory.tpl", {
    control_plane_ip = aws_instance.control_plane.public_ip
    worker_ips       = aws_instance.worker[*].public_ip
    ssh_key_path     = pathexpand(var.ssh_key_path)
  })
}

# SSH Connection Commands
output "ssh_control_plane" {
  description = "SSH command for control plane"
  value       = "ssh -i ${pathexpand(var.ssh_key_path)} ubuntu@${aws_instance.control_plane.public_ip}"
}

output "ssh_workers" {
  description = "SSH commands for worker nodes"
  value = [
    for idx, ip in aws_instance.worker[*].public_ip :
    "ssh -i ${pathexpand(var.ssh_key_path)} ubuntu@${ip}"
  ]
}