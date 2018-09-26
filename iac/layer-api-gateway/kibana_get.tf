resource "aws_api_gateway_integration" "kibana_get_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.demo.id}"
  resource_id             = "${aws_api_gateway_resource.kibana_resource.id}"
  http_method             = "${aws_api_gateway_method.kibana_get_method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.kibana_get_function.function_name}/invocations"
  integration_http_method = "POST"
}
