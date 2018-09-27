resource "aws_api_gateway_rest_api" "demo" {
  name        = "demo"
  description = "demo"
}

resource "aws_api_gateway_method_settings" "demo_env_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.demo.id}"
  stage_name  = "${aws_api_gateway_deployment.demo_env.stage_name}"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_authorizer" "demo" {
  name          = "demo"
  rest_api_id   = "${aws_api_gateway_rest_api.demo.id}"
  type          = "COGNITO_USER_POOLS"
  provider_arns = "${aws_cognito_user_pool.admin-pool.arn}"
}

resource "aws_api_gateway_deployment" "demo_env" {
  depends_on = []

  rest_api_id = "${aws_api_gateway_rest_api.demo.id}"
  stage_name  = "dev"
}

output "env_url" {
  value = "https://${aws_api_gateway_deployment.demo_env.rest_api_id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.demo_env.stage_name}"
}

resource "aws_api_gateway_resource" "demo_ressource" {
  rest_api_id = "${aws_api_gateway_rest_api.demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.demo.root_resource_id}"
  path_part   = "demo"
}

resource "aws_api_gateway_resource" "demo_users_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.demo.id}"
  parent_id   = "${aws_api_gateway_resource.demo_ressource.id}"
  path_part   = "kibana"
}
