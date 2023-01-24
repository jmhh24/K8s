##### Role Creation ##########
resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster"

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
##### Attach Role to Policy ##########
resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}
#### EKS Cluster Creation ######
resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = aws_iam_role.eks_cluster.arn
  
 

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access = true

    subnet_ids = [var.sub_private_1_id, var.sub_public_1_id, var.sub_private_2_id, var.sub_public_2_id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  ]
}
##### Node role creation #####
resource "aws_iam_role" "nodes_general" {
  name = "eks-node-group-general"

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
##### Node Role attach with Policies ####
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.nodes_general.name
  
}
resource "aws_iam_role_policy_attachment" "amazoneks_cni_poliy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.nodes_general.name
  
}
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.nodes_general.name
  
}
#### Group Node Creation ######
resource "aws_eks_node_group" "nodes_general" {
  cluster_name = aws_eks_cluster.eks.name
  node_group_name = "nodes-general"
  node_role_arn = aws_iam_role.nodes_general.arn
  subnet_ids = [var.sub_private_1_id, var.sub_private_2_id]
  scaling_config {
    desired_size = 2
    max_size = 2
    min_size = 2
  }
    ami_type = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
    disk_size = 20
    force_update_version = false
    instance_types = ["t3.small"]
    labels = {
      role = "nodes_general"
    }
    version = "1.23"
    depends_on = [
      aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
      aws_iam_role_policy_attachment.amazoneks_cni_poliy,
      aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
    ]
     
}
