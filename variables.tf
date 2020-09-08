variable "aws_region" {
  default = "ap-southeast-2"
  type    = string
}

variable "tags" {
  type = map
  default = {}
}

variable "aliases" {
  default = []
  type    = list
}

variable "domain" {
  type = string
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "other_endpoints" {
  type = list(object({
    endpoint = string
    path     = string
    pattern  = string
    origin   = string

  }))
  default = [{
    endpoint = "test.jorke.net"
    path     = ""
    pattern  = "this/is/a/path/*"
    origin   = "s3-another"
  }]
}

variable "wait_for_deployment" {
  type    = string
  default = true
}
