# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}
variable "aws_region" {
  default = "ap-northeast-2"
}

variable "cluster_name" {
  default = "rookies-final-eks"
  type    = string
}

variable "domain_name" {
  description = "The base domain for ExternalDNS configuration"
  type        = string
  default     = "shortpingoo.shop"
}


