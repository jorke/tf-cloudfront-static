# terraform template for s3 origin static website with ssl
creates:
 - an **s3 bucket** to put your static files into
 - a **Route 53** zone for the `domain`
 - an **ACM** ssl cert configured to validate on the Route53 zone above
 - a **Cloudfront** distribution pointing at all that

## Usage

```
provider "aws" {
  alias = "sydney"
  region = "ap-southeast-2"
}

module "static" {
  source = "git@github.com:jorke/tf-cloudfront-static.git//?ref=master"
  providers = {
    aws = aws.sydney
  }
  domain = "jorke.net"
  wait_for_deployment = false
}


```

## Copying files to s3

Using AWS cli (note: *no public-acl*)

```
aws s3 cp . s3://mybucket/ --recursive --region ap-southeast-2
```


###  Notes:

Serving of all content is via the CF distribution via https. eg https://jorke.net will refer to an s3 bucket whose content is *not* set to `public-acl`; using a cloudfront origin access identity to publish to cloudfront.

The other_endpoints is used for hooking up access to other origins such as apis on the same domain, obviously YMMV on this - however this is the safest setup I could get to for static files hosting for ~$1/month (cost of Route53 zone file)

Once the Route53 zone is established, your can either delegate your domain to the name servers or delegate the subdomain as needed. A targeted tf deployment can help with this eg: `-target module.static.aws_route53_zone.this`.


 ## Providers

 | Name | Version |
 |------|---------|
 | aws | n/a |
 | aws.useast | n/a |

 ## Inputs

 | Name | Description | Type | Default | Required |
 |------|-------------|------|---------|:-----:|
 | aliases | n/a | `list` | `[]` | no |
 | aws\_region | n/a | `string` | `"ap-southeast-2"` | no |
 | domain\_name | n/a | `string` | n/a | yes |
 | index\_document | n/a | `string` | `"index.html"` | no |
 | other\_endpoints | n/a | `list(object({endpoint = string, path = string, pattern = string, origin = string}))`|`[{"endpoint":"data.jorke.net","origin": "s3-another","path": "","pattern": "this/is/a/path/*"}]` | no |
 | tags | n/a | `map` | n/a | yes |
 | wait\_for\_deployment | n/a | `string` | `true` | no |



 ## Outputs

 | Name | Description |
 |------|-------------|
 | s3\_bucket | s3 bucket for deployment |
 | name_servers | route53 name servers |
