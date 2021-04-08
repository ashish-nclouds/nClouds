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


resource "datadog_dashboard" "ASHISH-DEMO-TITLE-001-ECS" {
  title        = "ASHISH-DEMO-TITLE-001-ECS"
  description  = "Created using the Datadog provider in Terraform"
  layout_type  = "free"
  is_read_only = false

  ###---------------------------- Adding Widgets HERE ----------------------------###
  ###---------------------------- Layout Grid line 01 ----------------------------###

  widget {
    image_definition {
      url    = "/static/images/logos/amazon-ecs_avatar.svg"
      sizing = "fit"
      margin = "large"
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
    check_status_definition {
      check      = "aws.status"
      grouping   = "cluster"
      tags       = ["service:ecs"]
      title_size = 13
      title      = "Check Status"
      live_span  = "1h"
    }
    layout = {
      height = 9
      width  = 15
      x      = 49
      y      = 0
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "100*sum:docker.containers.running{$ecs_cluster}.rollup(avg, 300)/(sum:docker.containers.running{$ecs_cluster}.rollup(avg, 300)+sum:docker.containers.stopped{$ecs_cluster}.rollup(avg, 300))"
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
      live_span   = "1h"
    }
    layout = {
      height = 8
      width  = 15
      x      = 49
      y      = 10
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:network.http.cant_connect{$ecs_cluster}, 1-avg:network.http.cant_connect{$ecs_cluster}"
        display_type = "area"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      request {
        q            = "avg:network.http.cant_connect{$ecs_cluster}, avg:network.http.cant_connect{$ecs_cluster}*100"
        display_type = "area"
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
      title       = "Prod Availability"
      live_span   = "1h"
    }
    layout = {
      height = 18
      width  = 28
      x      = 65
      y      = 0
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(sum:aws.ecs.running_tasks_count{$clustername} by {clustername}, 10, 'mean', 'desc')"
      }
      title_size = 13
      title      = "Containers Running by Cluster"
    }
    layout = {
      height = 18
      width  = 32
      x      = 94
      y      = 0
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:docker.cpu.user{$ecs_cluster} by {container_name}, 10, 'max', 'desc')"
      }
      title_size = 13
      title      = "Most CPU intensive containers"
    }
    layout = {
      height = 18
      width  = 32
      x      = 127
      y      = 0
    }
  }

  ###---------------------------- End of line 01 ----------------------------###

  ###---------------------------- Layout Grid line 02 ----------------------------###

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.applicationelb.healthy_host_count{$loadbalancer}"
        aggregator = "sum"
        conditional_formats {
          comparator = ">"
          value      = 0
          palette    = "white_on_green"
        }
        conditional_formats {
          comparator = "<"
          value      = 0
          palette    = "white_on_red"
        }
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Healthy Host"
      live_span  = "1h"
    }
    layout = {
      height = 10
      width  = 17
      x      = 0
      y      = 19
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.applicationelb.un_healthy_host_count{$loadbalancer}"
        aggregator = "sum"
        conditional_formats {
          comparator = "<="
          value      = 0
          palette    = "white_on_green"
        }
        conditional_formats {
          comparator = ">"
          value      = 0
          palette    = "white_on_red"
        }
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Unhealthy Host"
      live_span  = "1h"
    }
    layout = {
      height = 9
      width  = 17
      x      = 0
      y      = 30
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:aws.ecs.pending_tasks_count{$clustername}"
        aggregator = "last"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Pending tasks count"
      live_span  = "1h"
    }
    layout = {
      height = 6
      width  = 12
      x      = 18
      y      = 19
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:docker.containers.stopped{$ecs_cluster}"
        aggregator = "last"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "stopped Docker containers"
      live_span  = "1h"
    }
    layout = {
      height = 6
      width  = 12
      x      = 18
      y      = 26
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:aws.ecs.running_tasks_count{$clustername}"
        aggregator = "last"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Running tasks count"
      live_span  = "1h"
    }
    layout = {
      height = 6
      width  = 12
      x      = 18
      y      = 33
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.ecs.cpuutilization{$clustername}"
        aggregator = "avg"
        conditional_formats {
          comparator = "<="
          value      = 60
          palette    = "white_on_green"
        }
        conditional_formats {
          comparator = ">"
          value      = 60
          palette    = "white_on_yellow"
        }
        conditional_formats {
          comparator = ">"
          value      = 75
          palette    = "white_on_red"
        }
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "CPU Utilization"
      live_span  = "1h"
    }
    layout = {
      height = 20
      width  = 12
      x      = 31
      y      = 19
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:network.http.can_connect{$ecs_cluster}*100"
        aggregator = "avg"
        conditional_formats {
          comparator = "<"
          value      = 95
          palette    = "white_on_red"
        }
        conditional_formats {
          comparator = ">"
          value      = 95
          palette    = "white_on_green"
        }
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Prod Uptime"
      live_span  = "1h"
    }
    layout = {
      height = 20
      width  = 12
      x      = 44
      y      = 19
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "(sum:aws.ecs.running_tasks_count{$clustername}/(sum:aws.ecs.running_tasks_count{$clustername}+sum:aws.ecs.pending_tasks_count{$clustername}))*100"
        aggregator = "last"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Percent tasks running"
      live_span  = "1h"
    }
    layout = {
      height = 10
      width  = 17
      x      = 57
      y      = 19
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:docker.containers.running{$ecs_cluster}"
        aggregator = "avg"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Running Docker conatiners"
      live_span  = "1h"
    }
    layout = {
      height = 9
      width  = 17
      x      = 57
      y      = 30
    }
  }

  widget {
    event_stream_definition {
      query          = "sources:ecs"
      tags_execution = "and"      
      event_size     = "s"
      title          = "ECS Events"
      title_size     = 16
      title_align    = "left"
      live_span      = "1d"
    }
    widget_layout {
      height = 20
      width  = 84
      x      = 75
      y      = 19
    }
  }
  ###---------------------------- End of line 01 ----------------------------###

  ###---------------------------- Layout Grid line 02 ----------------------------###

  widget {
    note_definition {
      content          = "Running Containers by Service"
      background_color = "yellow"
      font_size        = "14"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 15
      width  = 12
      x      = 0
      y      = 41
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "top(avg:aws.ecs.service.running{$clustername} by {servicename}, 10, 'last', 'desc')"
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
      title       = "ECS Running containers by service"
      #live_span   = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 13
      y      = 41
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:aws.ecs.service.running{$clustername} by {servicename}, 10, 'last', 'desc')"
      }
      title = "ECS Running containers by service Top 10"
      #live_span = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 62
      y      = 41
    }    
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:aws.ecs.service.cpuutilization{$clustername} by {servicename}, 10, 'last', 'desc')"
      }
      title = "ECS CPU usage by service Top 10"
      #live_span = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 111
      y      = 41
    }    
  }

  ###---------------------------- End of line 02 ----------------------------###

  ###---------------------------- Layout Grid line 03 ----------------------------###

  widget {
    note_definition {
      content          = "CPU Utilization by Service"
      background_color = "yellow"
      font_size        = "14"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 15
      width  = 12
      x      = 0
      y      = 57
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.ecs.cpuutilization{$clustername} by {servicename}"
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
      title       = "ECS CPU usage by service"
      #live_span   = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 13
      y      = 57
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "top(avg:aws.ecs.service.cpuutilization{$clustername} by {servicename}, 10, 'last', 'desc')"
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
      title       = "ECS CPU usage by Cluster"
      #live_span   = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 62
      y      = 57
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:aws.ecs.cpuutilization{$clustername} by {servicename}, 10, 'last', 'desc')"
      }
      title = "ECS CPU usage"
      #live_span = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 111
      y      = 57
    }    
  }


  ###---------------------------- End of line 03 ----------------------------###

  ###---------------------------- Layout Grid line 04 ----------------------------###

  widget {
    note_definition {
      content          = "Memory Utilization by Service"
      background_color = "yellow"
      font_size        = "14"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 15
      width  = 12
      x      = 0
      y      = 73
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.ecs.service.memory_utilization{$clustername} by {servicename}, avg:aws.ecs.memory_utilization.maximum{$clustername} by {servicename}, avg:aws.ecs.memory_utilization.minimum{$clustername} by {servicename}"
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
      title       = "ECS Mem usage by service"
      #live_span   = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 13
      y      = 73
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.ecs.cluster.memory_utilization{$clustername} by {container_name,clustername}"
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
      title       = "ECS Memory Usage per Cluster"
      #live_span   = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 62
      y      = 73
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:aws.ecs.service.memory_utilization{$clustername} by {servicename}, 10, 'last', 'desc')"
      }
      title = "ECS Mem usage by service Top 10"
      #live_span = "1h"
    }
    layout = {
      height = 15
      width  = 48
      x      = 111
      y      = 73
    }    
  }

  ###---------------------------- End of line 04 ----------------------------###

  ###---------------------------- Layout Grid line 05 ----------------------------###

  widget {
    note_definition {
      content          = "AWS ELB"
      background_color = "pink"
      font_size        = "18"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 60
      width  = 12
      x      = 0
      y      = 89
    }    
  }

  widget {
    image_definition {
      url    = "/static/images/saas_logos/bot/amazon_alb.png"
      sizing = "center"
      margin = "large"
    }
    layout = {
      height = 18
      width  = 17
      x      = 13
      y      = 89
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.applicationelb.healthy_host_count{$loadbalancer}"
        aggregator = "sum"
        conditional_formats {
          comparator = ">"
          value      = 0
          palette    = "white_on_green"
        }
        conditional_formats {
          comparator = "<"
          value      = 0
          palette    = "white_on_red"
        }
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Healthy Host"
      live_span  = "1h"
    }
    layout = {
      height = 18
      width  = 14
      x      = 31
      y      = 89
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "avg:aws.applicationelb.un_healthy_host_count{$loadbalancer}"
        aggregator = "sum"
        conditional_formats {
          comparator = "<="
          value      = 0
          palette    = "white_on_green"
        }
        conditional_formats {
          comparator = ">"
          value      = 0
          palette    = "white_on_red"
        }
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Unhealthy Host"
      live_span  = "1h"
    }
    layout = {
      height = 18
      width  = 14
      x      = 46
      y      = 89
    }
  }

  widget {
    query_value_definition {
      request {
        q          = "sum:aws.applicationelb.request_count{$loadbalancer}.as_count()"
        aggregator = "sum"
      }
      autoscale  = true
      precision  = "0"
      text_align = "center"
      title_size = 13
      title      = "Requests per second (avg)"
      #live_span  = "1h"
    }
    layout = {
      height = 18
      width  = 23
      x      = 61
      y      = 89
    }
  }

  widget {
    note_definition {
      content          = "CONNECTION LATENCY"
      background_color = "yellow"
      font_size        = "18"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 5
      width  = 71
      x      = 13
      y      = 108
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.applicationelb.active_connection_count{$loadbalancer} by {loadbalancer}.as_count()"
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
      title       = "Active Connections Count"
      #live_span   = "1h"
    }
    layout = {
      height = 14
      width  = 35
      x      = 13
      y      = 114
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.applicationelb.target_response_time.average{$loadbalancer} by {loadbalancer}"
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
      title       = "ALB Response Time"
      #live_span   = "1h"
    }
    layout = {
      height = 14
      width  = 35
      x      = 49
      y      = 114
    }
  }

  widget {
    note_definition {
      content          = "HTTP error"
      background_color = "yellow"
      font_size        = "18"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 5
      width  = 71
      x      = 13
      y      = 129
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.applicationelb.httpcode_elb_4xx{$loadbalancer} by {loadbalancer}.as_count()"
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
      title       = "HTTP 4xx error"
      #live_span   = "1h"
    }
    layout = {
      height = 14
      width  = 35
      x      = 13
      y      = 135
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.applicationelb.httpcode_elb_5xx{$loadbalancer} by {loadbalancer}.as_count()"
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
      title       = "HTTP 5xx error"
      #live_span   = "1h"
    }
    layout = {
      height = 14
      width  = 35
      x      = 49
      y      = 135
    }
  }

  widget {
    note_definition {
      content          = "EC2 Instance"
      background_color = "pink"
      font_size        = "18"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "bottom"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 6
      width  = 74
      x      = 85
      y      = 89
    }    
  }

  widget {
    note_definition {
      content          = "AWS EC2 CPU Utilization and Network I/O"
      background_color = "pink"
      font_size        = "18"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 19
      width  = 12
      x      = 85
      y      = 96
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.ec2.cpuutilization{$ecs_cluster} by {host,autoscaling_group,name,environment}"
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
      title       = "AWS EC2 CPU Utilization"
      #live_span   = "1h"
    }
    layout = {
      height = 19
      width  = 30
      x      = 98
      y      = 96
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.ec2.network_in{$ecs_cluster} by {host,autoscaling_group,name,environment}, avg:aws.ec2.network_out{$ecs_cluster} by {host,autoscaling_group,name,environment}"
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
      title       = "AWS EC2 Network I/O"
      #live_span   = "1h"
    }
    layout = {
      height = 19
      width  = 30
      x      = 129
      y      = 96
    }
  }

  widget {
    note_definition {
      content          = "AWS EC2 Disk and Memory in Avg"
      background_color = "pink"
      font_size        = "18"
      text_align       = "center"
      show_tick        = true
      tick_edge        = "right"
      tick_pos         = "50%"
    }
    widget_layout {
      height = 18
      width  = 12
      x      = 85
      y      = 116
    }    
  }

  widget {
    timeseries_definition {
      request {
        q            = "(avg:system.disk.used{$ecs_cluster} by {host,autoscaling_group,name,environment}/avg:system.disk.total{$ecs_cluster} by {host,autoscaling_group,name,environment})*100"
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
      title       = "AWS EC2 Disk Avg"
      #live_span   = "1h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 98
      y      = 116
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "(avg:system.mem.used{$ecs_cluster} by {host,autoscaling_group,name,environment}/avg:system.mem.total{$ecs_cluster} by {host,autoscaling_group,name,environment})*100"
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
      title       = "AWS EC2 Memory in Avg"
      #live_span   = "1h"
    }
    layout = {
      height = 18
      width  = 30
      x      = 129
      y      = 116
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.applicationelb.target_response_time.average{$loadbalancer} by {loadbalancer}"
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
      title       = "Request count"
      #live_span   = "1h"
    }
    layout = {
      height = 14
      width  = 37
      x      = 85
      y      = 135
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.applicationelb.request_count{$loadbalancer} by {loadbalancer,targetgroup}.as_count()"
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
      title       = "ALB Target response time"
      #live_span   = "1h"
    }
    layout = {
      height = 14
      width  = 36
      x      = 123
      y      = 135
    }
  }

  ###---------------------------- End of line 05 ----------------------------###
  
  ###------------------------------ DONE Widgets ---------------------------------###



  ###---------------------------------- SCOPE ----------------------------------- ###
/*
  template_variable {
    name    = "scope"
    prefix  = "*"
    default = "*"
  }
*/
  template_variable {
    name    = "ecs_cluster"
    prefix  = "ecs_cluster"
    default = "prod-celery-ecs-2"
  }
/*
  template_variable {
    name    = "ecs_task"
    prefix  = "task_name"
    default = "*"
  }

  template_variable {
    name    = "name"
    prefix  = "name"
    default = "prod-celery-ecs-2"
  }

  template_variable {
    name    = "hostname"
    prefix  = "hostname"
    default = "prod-celery-ecs-2-139136883.us-west-2.elb.amazonaws.com"
  }
*/
  template_variable {
    name    = "clustername"
    prefix  = "clustername"
    default = "prod-celery-ecs-2"
  }

  template_variable {
    name = "loadbalancer"
    prefix = "loadbalancer"
    default = "app/prod-celery-ecs-2/b2f0f5501257435c"
  }
}