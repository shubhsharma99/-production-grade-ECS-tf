variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for bastion access"
  type        = string
}



variable "vpc_id" {
  description = "VPC ID where the bastion host will be deployed"
  type        = string
}

variable "public_subnet" {
  description = "Public subnet ID to launch the bastion host into"
  type        = string
}
