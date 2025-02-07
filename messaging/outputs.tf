output "msk_cluster_brokers_string" {
  value = aws_msk_cluster.kafka_cluster.bootstrap_brokers_tls
  description = "Bootstrap brokers string for MSK cluster (TLS)"
}
