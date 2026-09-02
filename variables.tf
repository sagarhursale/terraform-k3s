variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "master_instance_type" {
  description = "Instance type for master node"
  type        = string
  default     = "c7i-flex.large"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "c7i-flex.large"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "root_volume_size_master" {
  type    = number
  default = 30
}

variable "root_volume_size_worker" {
  type    = number
  default = 20
}

variable "k3s_token" {
  description = "Token used for K3s cluster join"
  type        = string
  default     = "sagar123supersecuretoken"
}

variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
  default     = "open"  
}