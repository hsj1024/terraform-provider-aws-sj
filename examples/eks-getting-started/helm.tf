# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config" # 또는 EKS 클러스터의 kubeconfig 경로
#   }
# }

# # AWS LoadBalancer Controller 설치
# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"  # Helm 차트 저장소 URL
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   set {
#     name  = "clusterName"
#     value = var.cluster_name
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "alb-controller-sa"
#   }

#   depends_on = [aws_iam_role.alb_controller_role]
# }
# # ExternalDNS IAM 역할에 필요한 권한 추가
# resource "aws_iam_role_policy" "external_dns_role_policy" {
#   name   = "external-dns-route53-access"
#   role   = aws_iam_role.external_dns_role.id
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = [
#           "route53:ChangeResourceRecordSets",
#           "route53:ListHostedZones",
#           "route53:ListResourceRecordSets"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # ExternalDNS Helm 차트 설치
# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"
#   namespace  = "kube-system"

#   set {
#     name  = "provider"
#     value = "aws"
#   }

#   set {
#     name  = "policy"
#     value = "sync" # CNAME 업데이트 자동화
#   }

#   set {
#     name  = "domainFilters[0]"
#     value = var.domain_name
#   }

#   set {
#     name  = "aws.zoneType"
#     value = "public"
#   }

#   depends_on = [aws_iam_role.external_dns_role, aws_iam_role_policy.external_dns_role_policy]
# }
