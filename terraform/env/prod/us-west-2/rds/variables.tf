variable "base_parameters" {
  type = list(object({
    name         = string,
    value        = any
    apply_method = string
  }))
  default = [
    {
      name         = "max_connections",
      value        = "LEAST({DBInstanceClassMemory/9531392},5000)",
      apply_method = "pending-reboot"
    },
    {
      name         = "maintenance_work_mem",
      value        = "GREATEST({DBInstanceClassMemory*1024/63963136},65536)",
      apply_method = "immediate"
    },
    {
      name         = "max_wal_size",
      value        = 2048,
      apply_method = "immediate"
    },
    {
      name         = "random_page_cost",
      value        = 1.1,
      apply_method = "immediate"
    },
    {
      name         = "effective_cache_size",
      value        = "{DBInstanceClassMemory/16384}",
      apply_method = "immediate"
    },
    {
      name         = "log_autovacuum_min_duration",
      value        = 10000,
      apply_method = "immediate"
    },
    {
      name         = "datestyle",
      value        = "iso, mdy",
      apply_method = "immediate"
    },
    {
      name         = "timezone",
      value        = "UTC",
      apply_method = "immediate"
    },
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
      name         = "track_activity_query_size",
      value        = 50000,
      apply_method = "pending-reboot"
    },
    {
      name         = "synchronous_commit",
      value        = "off",
      apply_method = "immediate"
    },
    {
      name         = "max_parallel_maintenance_workers",
      value        = "20",
      apply_method = "immediate"
    },
  ]
}

variable "enhanced_logging_parameters" {
  type = list(object({
    name         = string,
    value        = any
    apply_method = string
  }))
  default = [
    {
      name         = "datestyle",
      value        = "iso, mdy",
      apply_method = "immediate"
    },
    {
      name         = "timezone",
      value        = "UTC",
      apply_method = "immediate"
    },
    {
      name         = "log_statement",
      value        = "all",
      apply_method = "immediate"
    },
    {
      name         = "log_statement_sample_rate",
      value        = 0.1,
      apply_method = "immediate"
    },
    {
      name         = "log_min_duration_statement",
      value        = 5,
      apply_method = "immediate"
    },
    {
      name         = "log_autovacuum_min_duration",
      value        = 10000,
      apply_method = "immediate"
    },
    {
      name         = "log_checkpoints",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "log_connections",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "log_disconnections",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "log_duration",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "log_hostname",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "log_lock_waits",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "default_statistics_target",
      value        = 1000,
      apply_method = "immediate"
    },
    {
      name         = "vacuum_cost_delay",
      value        = 100,
      apply_method = "immediate"
    },
    {
      name         = "track_io_timing",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "track_wal_io_timing",
      value        = 1,
      apply_method = "immediate"
    },
    {
      name         = "track_functions",
      value        = "all",
      apply_method = "immediate"
    },
  ]
}