# Provider
# --------
terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
  required_version = ">= 0.13"
}

# API keys for the provider
# -------------------------
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

resource "datadog_dashboard" "Ashish-Demo-01" {
  title        = "Ashish-Demo-01"
  description  = "Created using the Datadog provider in Terraform"
  layout_type  = "free" 
  is_read_only = false

  ###---------------------------- Adding Widgets HERE ----------------------------###
  ###---------------------------- Layout Grid line 01 ----------------------------###

  widget {
    image_definition {
      url    = "https://www.nclouds.com/img/nclouds-logo.svg"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 18
      width  = 17
      x      = 0
      y      = 0
    }
  }


  widget {
    hostmap_definition {
      request {
        fill {
          q = "avg:system.load.5{$ecs_cluster} by {host}"
        }
      }
      node_type       = "host"
      no_metric_hosts = false
      no_group_hosts  = true
      scope           = ["$ecs_cluster"]
      style {
        palette      = "green_to_orange"
        palette_flip = false
        fill_min     = "auto"
        fill_max     = "auto"
      }
      title_size  = 13
      title_align = "center"
      title       = "HostMap"
    }
    layout = {
      height = 18
      width  = 30
      x      = 18
      y      = 0
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:docker.cpu.user{$scope,$ecs_cluster,$ecs_task} by {container_name}"
        display_type = "line"
        style {
          palette    = "warm"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      title_size  = 13
      title_align = "center"
      title       = "CPU  Uitilization"
    }
    layout = {
      height = 18
      width  = 30
      x      = 48
      y      = 0
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:docker.cpu.user{$scope,$ecs_cluster,$ecs_task} by {container_name}, 25, 'max', 'desc')"
      }
      title_size = 13
      title      = "Most CPU intensive containers"
    }
    layout = {
      height = 18
      width  = 30
      x      = 78
      y      = 0
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:system.load.5{*} by {host}, 10, 'mean', 'desc')"
        conditional_formats {
          comparator = ">"
          value      = "4"
          palette    = "white_on_red"
        }
        conditional_formats {
          comparator = ">="
          value      = "2"
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = "<"
          value      = "2"
          palette    = "white_on_green"
        }
      }
      title_size = 13
      title      = "System Load by Instances"
    }
    layout = {
      height = 18
      width  = 30
      x      = 108
      y      = 0
    }
  }

  ###---------------------------- Layout Grid line 02 ----------------------------###
  widget {
    image_definition {
      url    = "/static/images/saas_logos/bot/amazon_ecs.png"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 18
      width  = 17
      x      = 0
      y      = 19
    }
  }

  widget {
    check_status_definition {
      check    = "aws.status"
      grouping = "cluster"
      #group_by = ["account", "cluster"]
      #report_by = "service:ecs"      
      tags       = ["service:ecs"]
      title_size = 13
      title      = "Check Status"
      live_span  = "4h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 18
      y      = 19
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:docker.containers.running{$scope,$ecs_cluster,$ecs_task}"
        aggregator = "avg"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Running Docker containers"
      live_span  = "4h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 33
      y      = 19
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(sum:aws.ecs.running_tasks_count{$ecs_cluster} by {clustername}, 10, 'mean', 'desc')"
      }
      title_size = 13
      title      = "Containers Running by Cluster"
      live_span  = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 48
      y      = 19
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:docker.mem.rss{$scope,$ecs_cluster,$ecs_task} by {container_name}, 10, 'max', 'desc')"
      }
      title_size = 13
      title      = "Most RAM intensive containers 02"
      live_span  = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 78
      y      = 19
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:docker.mem.rss{$scope,$ecs_cluster,$ecs_task} by {container_name}"
        display_type = "line"
        style {
          palette    = "warm"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "Memory by container"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 108
      y      = 19
    }
  }

  ###---------------------------- Layout Grid line 03 ----------------------------###

  widget {
    image_definition {
      url    = "/static/images/screenboard/integrations/docker-logo-792x269.png"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 18
      width  = 17
      x      = 0
      y      = 38
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "100*sum:docker.containers.running{$scope,$ecs_cluster,$ecs_task}.rollup(avg, 300)/(sum:docker.containers.running{$scope,$ecs_cluster,$ecs_task}.rollup(avg, 300)+sum:docker.containers.stopped{$scope,$ecs_cluster,$ecs_task}.rollup(avg, 300))"
        aggregator = "avg"
        conditional_formats {
          comparator = ">="
          value      = 80
          palette    = "white_on_green"
        }
        conditional_formats {
          comparator = ">="
          value      = 50
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = ">="
          value      = 0
          palette    = "white_on_red"
        }
      }
      autoscale   = true
      custom_unit = "%"
      precision   = 0
      text_align  = "center"
      title_size  = 13
      title       = "Containers Health"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 18
      y      = 38
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:docker.containers.stopped{$scope,$ecs_cluster,$ecs_task}"
        aggregator = "avg"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "stopped Docker containers"
      live_span  = "4h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 33
      y      = 38
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "sum:aws.ecs.running_tasks_count{$ecs_cluster} by {clustername}.fill(0)"
        display_type = "bars"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "CPU  Uitilization"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 48
      y      = 38
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "sum:aws.ecs.running_tasks_count{$ecs_cluster} by {instance_id}.fill(0)"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "Running Containers by Instance"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 78
      y      = 38
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(max:aws.ecs.running_tasks_count{$ecs_cluster} by {instance_id}, 10, 'max', 'desc')"
        #conditional_formats {}
      }
      title_size = 13
      title      = "Containers Running by Instance"
    }
    layout = {
      height = 18
      width  = 30
      x      = 108
      y      = 38
    }
  }


  ###---------------------------- Layout Grid line 04 ----------------------------###

  widget {
    image_definition {
      url    = "/static/images/saas_logos/bot/redis.png"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 18
      width  = 17
      x      = 0
      y      = 57
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.elasticache.cpuutilization{engine:redis}"
        aggregator = "avg"
        conditional_formats {
          comparator = ">"
          value      = 50
          palette    = "white_on_red"
        }
        conditional_formats {
          comparator = ">"
          value      = 20
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = "<="
          value      = 20
          palette    = "white_on_green"
        }
      }
      autoscale  = true
      precision  = 2
      text_align = "center"
      title_size = 13
      title      = "CPU Utilization"
      live_span  = "4h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 18
      y      = 57
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.elasticache.bytes_used_for_cache{*}"
        aggregator = "avg"
      }
      autoscale  = true
      precision  = 2
      text_align = "center"
      title_size = 13
      title      = "Bytes used for Cache"
      live_span  = "1h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 33
      y      = 57
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.elasticache.freeable_memory{cluster:nopsprod}"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        include_zero = false
      }
      title_size  = 13
      title_align = "center"
      title       = "Elastcache Freeable Memory"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 48
      y      = 57
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.elasticache.cache_hits{$scope,$ecs_cluster} by {cacheclusterid}.as_count()"
        display_type = "bars"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      request {
        q            = "avg:aws.elasticache.cache_misses{$scope,$ecs_cluster} by {cacheclusterid}.as_count()"
        display_type = "bars"
        style {
          palette    = "warm"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "Elasticache Hits vs Misses"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 78
      y      = 57
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.elasticache.freeable_memory{cluster:nopsprod}"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = false
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "Elasticache Freeable Memory"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 108
      y      = 57
    }
  }

  ###---------------------------- Layout Grid line 05 ----------------------------###

  widget {
    image_definition {
      url    = "https://media.awslagi.com/2020/05/15151745/awslagi.com-amazon-rds-icon.png"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 18
      width  = 17
      x      = 0
      y      = 76
    }
  }


  widget {
    query_value_definition {
      request {
        q          = "avg:aws.rds.cpuutilization{$environment}"
        aggregator = "avg"
        conditional_formats {
          comparator = ">"
          value      = 75
          palette    = "white_on_red"
        }
        conditional_formats {
          comparator = ">"
          value      = 70
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = "<="
          value      = 69
          palette    = "white_on_green"
        }
      }
      autoscale  = true
      precision  = 2
      text_align = "center"
      title_size = 13
      title      = "RDS CPU Utilization"
      live_span  = "1h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 18
      y      = 76
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.rds.swap_usage{$environment}"
        aggregator = "avg"
      }
      autoscale  = true
      precision  = 2
      text_align = "center"
      title_size = 13
      title      = "RDS SWAP Usage"
      live_span  = "1h"
    }
    layout = {
      height = 18
      width  = 15
      x      = 33
      y      = 76
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.read_iops{$environment}.as_count()"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        include_zero = false
      }
      title_size  = 13
      title_align = "center"
      title       = "RDS Read IOPS"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 48
      y      = 76
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.write_iops{$environment} by {cacheclusterid}.as_count()"
        display_type = "bars"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "RDS Write IOPS"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 78
      y      = 76
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.disk_queue_depth{$environment}"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = false
        label        = ""
      }
      title_size  = 13
      title_align = "center"
      title       = "RDS Disk Queue Depth"
      live_span   = "4h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 108
      y      = 76
    }
  }

  ###------------------------------ DONE Widgets ---------------------------------###



  ###---------------------------------- SCOPE ----------------------------------- ###

  template_variable {
    name    = "scope"
    prefix  = "*"
    default = "*"
  }
  template_variable {
    name    = "ecs_cluster"
    prefix  = "ecs_cluster"
    default = "*"
  }

  template_variable {
    name    = "ecs_task"
    prefix  = "task_name"
    default = "*"
  }

  template_variable {
    name    = "environment"
    prefix  = "environment"
    default = "prod"
  }
}
