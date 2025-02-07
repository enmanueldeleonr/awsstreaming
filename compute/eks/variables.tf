variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs for the EKS cluster (Private Subnets)"
}

variable "eks_cluster_sg_id" {
  type        = string
  description = "Security Group ID for EKS Cluster Control Plane"
}

variable "worker_node_sg_id" {
  type        = string
  description = "Security Group ID for EKS Worker Nodes"
}
