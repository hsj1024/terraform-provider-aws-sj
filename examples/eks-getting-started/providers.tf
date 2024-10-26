# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#provider "kubernetes" {
#  host                   = aws_eks_cluster.your_cluster.endpoint
#  cluster_ca_certificate = base64decode(aws_eks_cluster.your_cluster.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.your_cluster.token
#  load_config_file= false # 사용 중인 config 파일을 로드하지 않음
#}
#data "aws_eks_cluster_auth" "your_cluster" {
#  name = aws_eks_cluster.your_cluster.name
#}

data "aws_availability_zones" "available" {}

# Not required: currently used in conjunction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}
