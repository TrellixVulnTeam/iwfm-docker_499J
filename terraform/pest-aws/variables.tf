variable "prefix" {
  description = "The prefix used for all resources"
  default = "iwfm-pest"
}

variable "region" {
  description = "The AWS region where all resources should be created"
  default = "us-east-2"
}

variable "instance_type" {
  description = "The type of AWS EC2 instance to use for the cluster"
  default = "c6i.metal"
}

variable "agent_count" {
  description = "Number of agent containers to use"
  default = 74
}

variable "instance_root_volume_size" {
  description = "The size of the root volume for cluster instances"
  default = "4000"
}

variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
}

variable "manager_image" {
  description = "Docker image"
  default = "ashesfall/iwfm-manager"
}

variable "agent_image" {
  description = "Docker image"
  default = "ashesfall/iwfm-agent"
}

variable "tag" {
  description = "Tag to use for the image"
  default = "latest"
}

variable "resource_bucket" {
  description = "A unique name for an S3 bucket to store the resources for the process"
}

variable "iwfm_model" {
  description = "The path to the IWFM model to run"
}

variable "pest_cmd" {
  description = "The kind of PEST++ operation to run"
  default = "glm"
}