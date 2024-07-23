locals {
  is_prod = strcontains(path.cwd, "terraform/env/prod") ? "prod" : "nonprod"
}

resource "aws_ssm_patch_baseline" "ubuntu_base" {
  name             = "MHC-Ubuntu-2204-base"
  description      = "MHC custom patch baseline for Ubuntu 22.04 base repos"
  operating_system = "UBUNTU"

  approval_rule {
    enable_non_security = true

    dynamic "patch_filter" {
      for_each = var.patch_filters
      content {
        key    = patch_filter.value["key"]
        values = patch_filter.value["values"]
      }
    }
  }

  dynamic "source" {
    for_each = var.sources
    content {
      name          = source.value["name"]
      products      = source.value["products"]
      configuration = source.value["configuration"]
    }
  }

  tags = {
    Name         = "MHC-Ubuntu-2204-base",
    isProduction = false,
    Terraform    = true
  }
}


resource "aws_iam_role" "auto_patching_role" {
  name               = "AutoPatchingNotificationRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sts_assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_policy" "sns_policy" {
  name        = "SnsPublishMhcAlerts"
  description = "Allow SNS to publish to MHC alerts"
  policy      = data.aws_iam_policy_document.sns_publish.json
}

resource "aws_iam_policy_attachment" "sns_publish_attach" {
  name       = "SnsPublishAttachment"
  roles      = [aws_iam_role.auto_patching_role.name]
  policy_arn = aws_iam_policy.sns_policy.arn
}

resource "aws_cloudwatch_log_group" "patching_log_group" {
  name              = "/mhc/auto-patching/${var.patch_group}"
  retention_in_days = 731

  tags = var.tags
}

resource "aws_ssm_patch_group" "patchgroup" {
  baseline_id = aws_ssm_patch_baseline.ubuntu_1804_base.id
  patch_group = var.patch_group
}

resource "aws_ssm_maintenance_window" "window" {
  name              = "MHC-monthly-${var.patch_group}-patching"
  description       = "MHC monthly patching maintenance window scheduled for the first Wednesday of the month"
  schedule          = "cron(0 6 ? * 4#1 *)"
  schedule_timezone = "America/Los_Angeles"
  duration          = 4
  cutoff            = 1

  tags = merge(
    {
      "Name" = "MHC-monthly-${var.patch_group}-patching"
    },
    var.tags
  )
}

resource "aws_ssm_maintenance_window_target" "target" {
  window_id     = aws_ssm_maintenance_window.window.id
  name          = "MHC-${var.patch_group}-maintenance-target"
  description   = "MHC maintenance window target used for auto patching"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:PatchGroup"
    values = [var.patch_group]
  }
}

resource "aws_ssm_maintenance_window_task" "run_patch_baseline" {
  name            = "MHC-${var.patch_group}-maintenance-task"
  max_concurrency = 10
  max_errors      = 2
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.window.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      output_s3_bucket     = data.terraform_remote_state.s3_patching_logs.outputs.patching_logs_bucket
      output_s3_key_prefix = "${local.is_prod}/${var.patch_group}"
      timeout_seconds      = 120
      service_role_arn     = aws_iam_role.auto_patching_role.arn

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }

      cloudwatch_config {
        cloudwatch_output_enabled = true
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patching_log_group.name
      }

      notification_config {
        notification_arn    = "arn:aws:sns:us-west-2:913835907225:fogops-alerts_2019010422102262370000000c"
        notification_events = ["All"]
        notification_type   = "Command"
      }
    }
  }
}
