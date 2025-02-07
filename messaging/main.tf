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
    encryption_at_rest {
      data_volume_kms_key_id = var.kms_key_alias_arn
    }
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
  }

  tags = {
    Name = "kafka-cluster"
  }
}
