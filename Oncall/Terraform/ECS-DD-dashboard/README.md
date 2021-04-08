# Datadog ECS Dashboard using Terraform

Terraform module for deploying pre-defined set of Dataodog dashboards in [datadog](https://www.datadoghq.com) using [terraform](https://www.terraform.io/)

## Dependencies

- terraform 0.13
- Datadog Integration Credential: `datadog_app_key` and `datadog_api_key`, retrieve from [Datadog: Intergration/APIs](https://app.datadoghq.com/account/settings#api)

## Usage

```
terraform init
terraform apply -var "datadog_api_key=xxxxxxxxxxxx" -var "datadog_app_key=xxxxxxxxxxxx"
```
Or
Create `terraform.tfvars` add the api and app key.

```
datadog_api_key   = "******************************"
datadog_app_key   = "***********************************"
```

## Management
As dashboard is a single resource and there is no option yet for reusing the widgets as modules.

## Schema
Reqired
- `layout_type` (String) The layout type of the dashboard, either 'free' or 'ordered'.
- `title` (String) The title of the dashboard.
- `widget` (Block List, Min: 1) The list of widgets to display on the dashboard.

List of some widget definition
```
- alert_graph_definition	- group_definition
- alert_value_definition	- service_level_objective_definition
- change_definition		- event_stream_definition
- distribution_definition	- event_timeline_definition
- check_status_definition	- free_text_definition
- heatmap_definition		- iframe_definition
- hostmap_definition		- image_definition
- note_definition		- log_stream_definition
- query_table_definition	- manage_status_definition
- query_value_definition	- trace_service_definition
- scatterplot_definition	- toplist_definition
- servicemap_definition		- timeseries_definition
```
## Sample Widget
This is timeseries definition, where we can add query and remember to use scope rather than using hardcoded variable.
```
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
```

**$loadbalancer** is a variable which is defined as **template_variable** for ex:
```
  template_variable {
    name = "loadbalancer"
    prefix = "loadbalancer"
    default = "*"
  }
```
We can specify the **default** value based on the  tags we used, `default = "prod"`

**NOTE** while considering `Screenboard` must consider the **widget-layout** need to define the `x`, `y`, `height` and `width` of widget. We are definging the widget size and placement on the canvas.
ex:
```   
 layout = {
      height = 14
      width  = 36
      x      = 123
      y      = 135
    }
```
## Execution
```
terraform init
terraform fmt
terraform plan -out "ecs-dash"
terraform apply "ecs-dash"
```
**terraform fmt** command is used to rewrite Terraform configuration files to a canonical format and style. This command applies a subset of the Terraform language style conventions, along with other minor adjustments for readability.


## Reference

- [Terraform Offical Doc on Datadog provider](https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/dashboard)
- [Managing Datadog with Terraform](https://www.datadoghq.com/blog/managing-datadog-with-terraform/)
