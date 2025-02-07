resource "aws_kms_key" "data_encryption_key" {
  description             = "${var.key_prefix} Data Encryption Key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms_key_policy.json
}

resource "aws_kms_alias" "data_encryption_key_alias" {
  name          = "alias/${var.key_prefix}-data-key"
  target_key_id = aws_kms_key.data_encryption_key.key_id
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid = "Enable IAM Policies"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    actions = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "Allow Service to use KMS Key"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com", "elasticache.amazonaws.com", "kafka.amazonaws.com", "eks.amazonaws.com"] # Added eks.amazonaws.com
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}
