variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"

}

variable "vpc_name" {
  description = "Name of the VPC"
  default     = "demo-vpc"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "private_subnet" {
  description = "CIDR block for the private subnet"
  default = {
    "private_subnet_1" = 1
    "private_subnet_2" = 2
    "private_subnet_3" = 3
  }

}

variable "public_subnet" {
  description = "CIDR block for the public subnet"
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
    "public_subnet_3" = 3
  }

}