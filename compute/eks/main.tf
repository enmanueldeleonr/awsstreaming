resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.eks_cluster_sg_id]
  }

  encryption_config { # KMS Encryption for EKS Secrets
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_alias_arn 
    }
  }

  depends_on = [aws_iam_policy_attachment.eks_cluster_policy]
}


resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.micro"]
  ami_type        = "AL2_x86_64"
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  labels = {
    "node.eks.amazonaws.com/nodegroup-name" = "${var.cluster_name}-workers"
  }



  depends_on = [aws_iam_policy_attachment.eks_node_policy]
}





# IAM Roles and Policies for EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "eks_cluster_policy" {
  name       = "EKSClusterPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles  = [aws_iam_role.eks_cluster_role.name]
}


resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy_attachment" "eks_node_policy" {
  name       = "EKSNodePolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  roles  = [aws_iam_role.eks_node_role.name]
}

resource "aws_iam_policy_attachment" "eks_cni_policy" {
  name       = "EKSCNIPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  roles  = [aws_iam_role.eks_node_role.name]
}

resource "aws_iam_policy_attachment" "ec2_container_registry_readonly" {
  name       = "EC2ContainerRegistryReadOnlyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles  = [aws_iam_role.eks_node_role.name]
}