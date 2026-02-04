output "control_plane_ip" {
  value = aws_instance.control_plane.public_ip
}

output "worker_ips" {
  value = aws_instance.workers[*].public_ip
}

