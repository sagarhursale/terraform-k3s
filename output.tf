output "master_public_ip" {
  description = "Public IP of Master Node"
  value       = aws_instance.master.public_ip
}

output "worker_public_ips" {
  description = "Public IPs of Worker Nodes"
  value       = aws_instance.worker[*].public_ip
}