###########################################
# General Configuration
###########################################

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.33"
}

###########################################
# VPC & Subnet Configuration
###########################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

###########################################
# NAT Gateway Configuration
###########################################

variable "enable_nat_gateway" {
  description = "Determines whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Determines whether to use a single NAT Gateway (true) or one per AZ (false)"
  type        = bool
  default     = false
}

###########################################
# EKS Access Control
###########################################

variable "allowed_cidr" {
  description = "CIDR from which the EKS public endpoint can be accessed"
  type        = string
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to grant cluster admin access to the Terraform identity"
  type        = bool
  default     = false
}

###########################################
# EKS Endpoint Access
###########################################

variable "cluster_endpoint_public_access" {
  description = "Enable the Amazon EKS public API server endpoint"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Enable the Amazon EKS private API server endpoint"
  type        = bool
  default     = true
}

###########################################
# EKS Node Groups
###########################################

variable "eks_managed_node_groups" {
  description = "Map of EKS managed node groups to create (empty map = none)"
  type        = any
  default     = {}
}
