###### Secondary cidr #####

variable "subnet_a_cidr" {
  default     = null
  type        = string
  description = "The IPv4 CIDR block assigned to the subnet_a"
}

variable "subnet_b_cidr" {
  type        = string
  default     = null
  description = "The IPv4 CIDR block assigned to the subnet_b"
} 
variable "subnet_c_cidr" {
  type        = string
  default     = null
  description = "The IPv4 CIDR block assigned to the subnet_c"
} 

variable "parameter_vpc_id_name" {
  type        = string
  default     = null
  description = "SSM parameter name to store vpc id"
}

variable "parameter_transit_gateway" {
  type        = string
  default     = null
  description = "Id of the transit gate-way"
}

variable "parameter_sec_vpc_cidr" {
  type        = string
  default     = "100.65.0.0/16"
  description = "secondary IP cidr assigned to the VPC"
}

variable "create_vpc_sec_cidr" {
  type        = bool
  default     = false
  description = "create secondary cidr integration with vpc if true"
}

variable "parameter_subnet_idb" {
  type        = string
  default     = null
  description = "SSM parameter name to store subnet id b of secondary cidr"
}

variable "parameter_subnet_idc" {
  type        = string
  default     = null
  description = "SSM parameter name to store subnet id c of secondary cidr"
}

variable "parameter_subnet_ida" {
  type        = string
  default     = null
  description = "SSM parameter name to store subnet id a of secondary cidr"
}

variable "subnet_a_name"  {
  type        = string
  default     = "subnet-azA"
  description = "The name tag to assign to subnet A"
}

variable "subnet_b_name"  {
  type        = string
  default     = "subnet-azB"
  description = "The name tag to assign to subnet B"
}

variable "subnet_c_name"  {
  type        = string
  default     = "subnet-azC"
  description = "The name tag to assign to subnet C"
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}
