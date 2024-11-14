# resource "kubernetes_ingress" "argocd_ingress" {
#   metadata {
#     name      = "argocd-ingress"
#     namespace = "argocd"
#     annotations = {
#       "kubernetes.io/ingress.class"                          = "alb"
#       "external-dns.alpha.kubernetes.io/hostname"           = "argocd.${var.domain_name}" # Route 53에서 자동으로 DNS 설정
#     }
#   }

#   spec {
#     rule {
#       host = "argocd.${var.domain_name}"

#       http {
#         path {
#           path = "/"
#           backend {
#             service_name = "argocd-server"
#             service_port = "80"
#           }
#         }
#       }
#     }
#   }
# }
