provider "aws" {
  profile = "mhc"
  region = "us-west-2"
}

#convert this to a map of tg_name to ALB_name
#variable "ALB_info" {
#  type = map
#
#  default = {
#      #Production-ALB1 	= "plogw-TG"
#      #QA-ALB1		= "qalogw-TG"
#      #QB-ALB1		= "qblogw-TG"
#      qalog-elb = "qalog-group"
#      QAS01ALB1 = "QAS01TG1"
#      qas01w1   = "qas01w1"
#      qas02w1   = "qas02w1"
#      qas04	= "qas04tg1"
#      qblog 	= "qblog"
#      qbs01	= "qbs01"
#      qbs02	= "qbs02"
#      PLOGALB1 	= "PLOGTG1"
#      PS01ALB1 	= "PS01TG1"
#      PS02ALB1	= "PS02TG1"
#      PS03ALB1 	= "PS03TG1"
#      PS04ALB1 	= "PS04TG1"
#      PS05ALB1 	= "PS05TG1"
#      bscqa 	= "bscqatg"
#      bscqb 	= "bscqbtg"
#    }
#}

variable "ALB_info" {
  type = map

  default = {
    plogw-TG      = "Production-ALB1"
    plogw1-TG     = "Production-ALB1"
    ps01w-all-TG  = "Production-ALB1"
    ps01w1-TG     = "Production-ALB1"
    ps02w-all-TG  = "Production-ALB1"
    ps02w1-TG     = "Production-ALB1"
    ps03w-all-TG  = "Production-ALB1"
    ps03w1-TG     = "Production-ALB1"
    ps04w-all-TG  = "Production-ALB1"
    ps04w1-TG     = "Production-ALB1"
    ps05w-all-TG  = "Production-ALB1"
    ps05w1-TG     = "Production-ALB1"
    qalogw-TG     = "QA-ALB1"
    qalogw1-TG    = "QA-ALB1"
    qas01w-all-TG = "QA-ALB1"
    qas01w1-TG    = "QA-ALB1"
    qas02w-all-TG = "QA-ALB1"
    qas01w1-TG    = "QA-ALB1"
    qas03w-all-TG = "QA-ALB1"
    qas03w1-TG    = "QA-ALB1"
    qas04w-all-TG = "QA-ALB1"
    qas04w1-TG    = "QA-ALB1"
    qblogw-TG     = "QB-ALB1"
    qblogw1-TG    = "QB-ALB1"
    qbs01w-all-TG = "QB-ALB1"
    qbs01w1-TG    = "QB-ALB1"
    qbs02w-all-TG = "QB-ALB1"
    qbs02w1-TG    = "QB-ALB1"
    # bscqatg       = "bscqa"
    # bscqbtg       = "bscqb"
  }
}

data "aws_alb" "ALB_name" {
  for_each = var.ALB_info
  ##name = each.key #
  name = each.value
}

data "aws_alb_target_group" "ALB_TG" {
  for_each = var.ALB_info
  ##name = each.value #
  name = each.key
}

resource "aws_cloudwatch_metric_alarm" "alb-hhc" {
  for_each            = var.ALB_info
  alarm_name          = each.key #alarm_name needs to be ALB_name-tgname
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Number of X healthy nodes in Target Group"
  treat_missing_data  = "breaching"
  #alarm_actions 	= [ module.alb_fixed_response.sns_topic_arn ]
  #ok_actions		= [ module.alb_fixed_response.sns_topic_arn ]
  dimensions = {
    ##TargetGroup  = "${lookup(data.aws_alb_target_group.ALB_TG, each.key).arn_suffix}"
    ##LoadBalancer = "${lookup(data.aws_alb.ALB_name, each.key).arn_suffix}"
    TargetGroup  = "${lookup(data.aws_alb_target_group.ALB_TG, each.key).arn_suffix}"
    LoadBalancer = "${lookup(data.aws_alb.ALB_name, each.key).arn_suffix}"
  }
}
