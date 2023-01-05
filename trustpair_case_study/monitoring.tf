resource "aws_cloudwatch_metric_alarm" "gateway_error_rate" {
  alarm_name          = "gateway-4xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_description   = "Gateway error rate has exceeded 1%"
  treat_missing_data  = "missing"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0.05
  statistic           = "Sum"
  dimensions = {
    ApiName = "${aws_apigatewayv2_api.lambda.name}"
  }
}