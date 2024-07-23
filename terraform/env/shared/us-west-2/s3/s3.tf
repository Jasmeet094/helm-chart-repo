module "patching_logs_bucket" {
  source = "../../../../modules/s3"

  bucket_name = "mhc-patching-logs"
}