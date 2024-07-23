terraform {
  backend "s3" {
    bucket  = "mhc-terraform-us-west-2"
    key     = "ps14-shard.tf" #Update new shard here
    region  = "us-west-2"
    profile = "mhc" #replace your-name-here with your aws username
  }
}
