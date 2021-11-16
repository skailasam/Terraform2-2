resource "aws_s3_bucket" "s3-bucket" {
    bucket = "${var.bucket_name}" 
    acl = "${var.acl_value}"   
}