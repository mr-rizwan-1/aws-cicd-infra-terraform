variable "region" {
  type    = string
  default = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name (for SSH)"
  type        = string
}

variable "my_ip" {
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32"
  type        = string
}

variable "jenkins_instance_type" {
  type    = string
  default = "t3.small"
}

variable "app_instance_type" {
  type    = string
  default = "t3.micro"
}