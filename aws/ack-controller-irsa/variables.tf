variable "ack_policies" {
  type = map(string)
  default = {
    "elasticache" = "AmazonElastiCacheFullAccess"
    "eventbridge" = "AmazonEventBridgeFullAccess"
    "kms"         = "AWSKeyManagementServicePowerUser"
    "mq"          = "AmazonMQFullAccess"
    "rds"         = "AmazonRDSFullAccess"
    "s3"          = "AmazonS3FullAccess"
    "sqs"         = "AmazonSQSFullAccess"
  }
}