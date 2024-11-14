
#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "rookies-final-node" {
  name = "terraform-eks-rookies-final-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "rookies-final-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.rookies-final-node.name
}

resource "aws_iam_role_policy_attachment" "rookies-final-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.rookies-final-node.name
}

resource "aws_iam_role_policy_attachment" "rookies-final-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.rookies-final-node.name
}

resource "aws_eks_node_group" "rookies-final" {
  cluster_name    = aws_eks_cluster.rookies-final-cluster.name
  node_group_name = "rookies-final"
  node_role_arn   = aws_iam_role.rookies-final-node.arn
  #subnet_ids      = aws_subnet.rookies-final[*].id
  subnet_ids = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)


  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.rookies-final-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.rookies-final-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.rookies-final-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
