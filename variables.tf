variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "New-Tom"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space."
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.micro"
}
