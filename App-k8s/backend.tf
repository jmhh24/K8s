#terraform {
#  backend  "s3" {
#    bucket = "myS3"
#    key = "main"
#    region = "us-east-1"
#    dynamodb_table = "tf_state"
#  }
#}