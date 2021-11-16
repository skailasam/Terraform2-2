variable "bucket_name" {
    type = string
    default = "S3"
    description = "The Value of the Name; default is 'S3' "
}

variable "acl_value" {
    type = string
    default = "private"
    description = "the acl value; default is 'private'"
}