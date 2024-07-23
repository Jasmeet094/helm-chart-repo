variable "cctests01db_parameters" {
  type = list(object({
    name         = string,
    value        = any
    apply_method = string
  }))
  default = [
    {
      name         = "lc_messages",
      value        = "en_US.UTF-8",
      apply_method = "immediate"
    },
    {
      name         = "lc_monetary",
      value        = "en_US.UTF-8",
      apply_method = "immediate"
    },
    {
      name         = "lc_numeric",
      value        = "en_US.UTF-8",
      apply_method = "immediate"
    },
    {
      name         = "lc_time",
      value        = "en_US.UTF-8",
      apply_method = "immediate"
    },
    {
      name         = "maintenance_io_concurrency",
      value        = "40",
      apply_method = "immediate"
    },
    {
      name         = "maintenance_work_mem",
      value        = "52428800",
      apply_method = "immediate"
    },
    {
      name         = "max_parallel_maintenance_workers",
      value        = "20",
      apply_method = "immediate"
    },
    {
      name         = "max_wal_size",
      value        = "204800",
      apply_method = "immediate"
    },
    {
      name         = "synchronous_commit",
      value        = "off",
      apply_method = "immediate"
    },
    {
      name         = "track_activity_query_size",
      value        = "50000",
      apply_method = "pending-reboot"
    }
  ]
}