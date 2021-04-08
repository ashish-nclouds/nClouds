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

resource "datadog_dashboard" "Ashish-DEMO-Dashboard-03-RDS" {
  title        = "ASHISH-DEMO-TITLE-03-RDS"
  description  = "Created using the Datadog provider in Terraform"
  layout_type  = "free"
  is_read_only = false

  ###---------------------------- Adding Widgets HERE ----------------------------###
  ###---------------------------- Layout Grid line 01 ----------------------------###

  widget {
    image_definition {
      url    = "https://media.awslagi.com/2020/05/15151745/awslagi.com-amazon-rds-icon.png"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 12
      width  = 25
      x      = 0
      y      = 0
    }
  }

  widget {
    image_definition {
      url    = "/static/images/logos/mysql_large.svg"
      sizing = "fit"
      margin = "small"
    }
    layout = {
      height = 12
      width  = 25
      x      = 26
      y      = 0
    }
  }

  widget {
    check_status_definition {
      check    = "aws.status"
      grouping = "cluster"
      #group_by = ["account", "cluster"]
      #report_by = "service:ecs"      
      tags      = ["service:rds"]
      title     = "RDS service status"
      live_span = "30m"
    }
    layout = {
      height = 12
      width  = 25
      x      = 52
      y      = 0
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:trace.mysql.query.duration.by_type{$scope}"
        aggregator = "avg"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title      = "Query duration"
      live_span  = "1h"
    }
    layout = {
      height = 12
      width  = 17
      x      = 78
      y      = 0
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:trace.MySQLdb.connection.commit{$scope}.as_count()"
        aggregator = "avg"
        conditional_formats {
          palette    = "white_on_red"
          value      = 1
          comparator = ">"
        }
      }
      autoscale  = true
      precision  = "2"
      text_align = "center"
      title      = "DB Connection Commit"
      live_span  = "1h"
    }
    layout = {
      height = 12
      width  = 17
      x      = 96
      y      = 0
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:aws.rds.cpuutilization{name:nclouds-prod}.as_count()"
        aggregator = "avg"
        conditional_formats {
          palette    = "white_on_red"
          value      = 80
          comparator = ">"
        }
        conditional_formats {
          palette    = "white_on_yellow"
          value      = 71
          comparator = ">"
        }
        conditional_formats {
          palette    = "white_on_green"
          value      = 70
          comparator = ">"
        }
      }
      autoscale  = true
      precision  = "2"
      text_align = "center"
      title      = "RDS Prod CPU utilization"
      live_span  = "1h"
    }
    layout = {
      height = 12
      width  = 18
      x      = 114
      y      = 0
    }
  }

  widget {
    note_definition {
      content          = "Overall"
      background_color = "blue"
      font_size        = "14"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
    layout = {
      height = 5
      width  = 39
      x      = 13
      y      = 14
    }
  }

  widget {
    note_definition {
      content          = "Reads"
      background_color = "green"
      font_size        = "14"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
    layout = {
      height = 5
      width  = 39
      x      = 53
      y      = 14
    }
  }

  widget {
    note_definition {
      content          = "Writes"
      background_color = "orange"
      font_size        = "14"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
    layout = {
      height = 5
      width  = 39
      x      = 93
      y      = 14
    }
  }

  widget {
    note_definition {
      content          = "Query Volume"
      background_color = "yellow"
      font_size        = "22"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    layout = {
      height = 41
      width  = 12
      x      = 0
      y      = 20
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.read_throughput{$scope} by {dbinstanceidentifier}.as_count()"
        display_type = "line"
        style {
          palette    = "cool"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Read Throughput"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 13
      y      = 20
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.queries{$scope} by {name}.as_count()"
        display_type = "line"
        style {
          palette    = "green"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Read Queries"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 53
      y      = 20
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.deadlocks{$scope}.as_count()"
        display_type = "line"
        style {
          palette    = "orange"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "RDS Deadlocks"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 93
      y      = 20
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.swap_usage{$scope} by {name}"
        display_type = "line"
        style {
          palette    = "cool"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "RDS Swap usage"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 13
      y      = 41
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:aws.rds.volume_read_iops{$scope} by {name}, 10, 'mean', 'desc')"
        conditional_formats {
          comparator = ">"
          value      = "80"
          palette    = "white_on_red"
        }
        conditional_formats {
          comparator = ">="
          value      = "75"
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = "<"
          value      = "60"
          palette    = "white_on_green"
        }
      }
      title     = "Volume Read IOPS max"
      live_span = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 53
      y      = 41
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:aws.rds.volume_write_iops{$scope} by {name}, 10, 'mean', 'desc')"
        conditional_formats {
          comparator = ">"
          value      = "1000"
          palette    = "white_on_red"
        }
        conditional_formats {
          comparator = ">="
          value      = "980"
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = "<"
          value      = "950"
          palette    = "white_on_green"
        }
      }
      title     = "Volume Write IOPS max"
      live_span = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 93
      y      = 41
    }
  }

  widget {
    note_definition {
      content          = "Disk I/O"
      background_color = "green"
      font_size        = "22"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    layout = {
      height = 41
      width  = 12
      x      = 0
      y      = 62
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.read_iops{$engine} by {dbinstanceidentifier}.as_rate()+avg:aws.rds.write_iops{engine:mysql} by {dbinstanceidentifier}.as_rate()"
        display_type = "line"
        style {
          palette    = "blue"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Total I/O"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 13
      y      = 62
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.read_iops{$engine} by {dbinstanceidentifier}.as_rate()"
        display_type = "line"
        style {
          palette    = "green"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Read I/O"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 53
      y      = 62
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.write_iops{$engine} by {dbinstanceidentifier}.as_rate()"
        display_type = "line"
        style {
          palette    = "orange"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Write I/O"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 93
      y      = 62
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.disk_queue_depth{$engine} by {dbinstanceidentifier}"
        display_type = "line"
        style {
          palette    = "blue"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Disk Queue Depth"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 13
      y      = 83
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.read_latency{$engine} by {dbinstanceidentifier}"
        display_type = "line"
        style {
          palette    = "green"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Read latency per I/O"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 53
      y      = 83
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.rds.write_latency{$engine} by {dbinstanceidentifier}"
        display_type = "line"
        style {
          palette    = "orange"
          line_type  = "solid"
          line_width = "thin"
        }
      }
      yaxis {
        scale        = "linear"
        min          = "auto"
        max          = "auto"
        include_zero = true
        label        = ""
      }
      title_size  = 14
      title_align = "center"
      title       = "Write latency per I/O"
      live_span   = "1h"
    }
    layout = {
      height = 20
      width  = 39
      x      = 93
      y      = 83
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
    name    = "environment"
    prefix  = "environment"
    default = "prod"
  }

  template_variable {
    name    = "engine"
    prefix  = "engine"
    default = "mysql"
  }

}