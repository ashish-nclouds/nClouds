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

resource "datadog_dashboard" "Ashish-DEMO-Dashboard-02" {
  title        = "ASHISH-DEMO-TITLE-02"
  description  = "Created using the Datadog provider in Terraform"
  layout_type  = "ordered"
  is_read_only = false

  ###---------------------------- Adding Widgets HERE ----------------------------###
  ###---------------------------- Layout Grid line 01 ----------------------------###

  widget {
    image_definition {
      #url    = "https://www.linuxsysadmins.com/wp-content/uploads/2019/06/Amazon-EC2-Instance.png"
      url    = "https://www.nclouds.com/img/nclouds-logo.svg"
      sizing = "fit"
      margin = "small"
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
      title_size  = 20
      title_align = "center"
      title       = "HostMap"
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
      title_size  = 20
      title_align = "center"
      title       = "CPU  Uitilization"
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:docker.cpu.user{$scope,$ecs_cluster,$ecs_task} by {container_name}, 25, 'max', 'desc')"
      }
      title = "Most CPU intensive containers"
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
      title = "System Load by Instances"
    }
  }

  ###---------------------------- Layout Grid line 02 ----------------------------###
  widget {
    image_definition {
      url    = "/static/images/saas_logos/bot/amazon_ecs.png"
      sizing = "fit"
      margin = "small"
    }
  }

  widget {
    check_status_definition {
      check    = "aws.status"
      grouping = "cluster"
      #group_by = ["account", "cluster"]
      #report_by = "service:ecs"      
      tags  = ["service:ecs"]
      title = "Check Status"
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
      title      = "Running Docker containers"
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(sum:aws.ecs.running_tasks_count{$ecs_cluster} by {clustername}, 10, 'mean', 'desc')"
      }
      title = "Containers Running by Cluster"
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(avg:docker.mem.rss{$scope,$ecs_cluster,$ecs_task} by {container_name}, 10, 'max', 'desc')"
      }
      title = "Most RAM intensive containers 02"
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
      title_size  = 16
      title_align = "center"
      title       = "Memory by container"
    }
  }

  ###---------------------------- Layout Grid line 03 ----------------------------###

  widget {
    image_definition {
      url    = "/static/images/screenboard/integrations/docker-logo-792x269.png"
      sizing = "fit"
      margin = "small"
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
      title       = "Containers Health"
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
      title      = "stopped Docker containers"
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
      title_size  = 20
      title_align = "center"
      title       = "CPU  Uitilization"
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
      title_size  = 16
      title_align = "center"
      title       = "Running Containers by Instance"
    }
  }

  widget {
    toplist_definition {
      request {
        q = "top(max:aws.ecs.running_tasks_count{$ecs_cluster} by {instance_id}, 10, 'max', 'desc')"
        #conditional_formats {}
      }
      title = "Containers Running by Instance"
    }
  }


  ###---------------------------- Layout Grid line 04 ----------------------------###

  widget {
    image_definition {
      url    = "/static/images/saas_logos/bot/redis.png"
      sizing = "fit"
      margin = "small"
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
      title      = "CPU Utilization"
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
      title      = "Bytes used for Cache"
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
      title_size  = 16
      title_align = "center"
      title       = "Elasticache Freeable Memory"
    }
  }

  ###------------------------------ DONE - Widgets ---------------------------------###



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
}