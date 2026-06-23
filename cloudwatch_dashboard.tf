resource "aws_cloudwatch_dashboard" "traefik" {
  count          = var.enable_metrics ? 1 : 0
  dashboard_name = "${var.project}-${var.environment}-traefik"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 9
        properties = {
          title  = "Requests per service"
          view   = "timeSeries"
          region = var.region
          period = 300
          stat   = "Sum"
          metrics = [
            [{ expression = "SELECT SUM(traefik_service_requests_total) FROM SCHEMA(\"ContainerInsights/Prometheus\", service, code) GROUP BY service", id = "q1" }]
          ]
          yAxis = { left = { min = 0 } }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 9
        width  = 12
        height = 10
        properties = {
          title  = "Total requests per router — ranking"
          view   = "table"
          region = var.region
          period = 86400
          stat   = "Sum"
          metrics = [
            [{ expression = "SELECT SUM(traefik_router_requests_total) FROM SCHEMA(\"ContainerInsights/Prometheus\", router) GROUP BY router ORDER BY SUM() DESC LIMIT 20", id = "q2" }]
          ]
        }
      }
    ]
  })
}