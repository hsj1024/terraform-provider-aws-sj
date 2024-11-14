# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster


resource "aws_iam_role" "rookies-final-cluster" {
  name = "terraform-eks-rookies-final-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "rookies-final-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.rookies-final-cluster.name
}

resource "aws_iam_role_policy_attachment" "rookies-final-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.rookies-final-cluster.name
}

resource "aws_security_group" "rookies-final-cluster" {
  name        = "terraform-eks-rookies-final-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.rookies-final.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rookies-final-eks"
  }
}

resource "aws_security_group_rule" "rookies-final-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.rookies-final-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "rookies-final-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.rookies-final-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.rookies-final-cluster.id]
    # 퍼블릭과 프라이빗 서브넷을 모두 포함하도록 설정
    subnet_ids = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
  }
  #subnet_ids         = aws_subnet.rookies-final[*].id


  depends_on = [
    aws_iam_role_policy_attachment.rookies-final-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.rookies-final-cluster-AmazonEKSVPCResourceController,
  ]

}

