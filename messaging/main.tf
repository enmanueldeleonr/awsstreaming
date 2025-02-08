resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = var.kafka_cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.kafka_broker_nodes

  broker_node_group_info {
    client_subnets = var.private_subnet_ids # Private subnets for MSK
    instance_type  = var.kafka_instance_type
    security_groups = [var.msk_cluster_sg_id]
  }

  encryption_info {

    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
  }

  tags = {
    Name = "kafka-cluster"
  }
}
