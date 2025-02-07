resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  egress { # Allow all outbound from cluster control plane
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

resource "aws_security_group" "eks_worker_node_sg" {
  name        = "eks-worker-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress { # Allow worker nodes to communicate with cluster control plane
    from_port   = 443 # EKS Control Plane port
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }
  ingress { # Allow worker nodes to communicate within their SG
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self          = true
  }
  egress { # Allow all outbound from worker nodes
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "eks-worker-node-sg"
  }
}

resource "aws_security_group" "rds_postgres" {
  name        = "rds-postgres-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 5432 # PostgreSQL port
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [aws_security_group.eks_worker_node_sg.id] # Allow from worker nodes SG
  }
  egress { # Allow all outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}


resource "aws_security_group" "elasticache_redis" {
  name        = "elasticache-redis-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 6379 # Redis port
    to_port          = 6379
    protocol         = "tcp"
    security_groups = [aws_security_group.eks_worker_node_sg.id] # Allow from worker nodes SG
  }
  egress { # Allow all outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "elasticache-redis-sg"
  }
}


resource "aws_security_group" "msk_cluster" {
  name        = "msk-cluster-sg"
  description = "Security group for MSK cluster"
  vpc_id      = var.vpc_id

  ingress { # Allow from worker nodes SG - adjust ports as needed for Kafka
    from_port        = 9092 # Default Kafka port (Not secured)
    to_port          = 9098 
    protocol         = "tcp"
    security_groups = [aws_security_group.eks_worker_node_sg.id] # Allow from worker nodes SG
  }
  egress { # Allow all outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "msk-cluster-sg"
  }
}