
resource "aws_cognito_user_pool" "admin-pool" {
  name = "admin-pool"

  alias_attributes = ["email"]

  admin_create_user_config {
      allow_admin_create_user_only = true
      unused_account_validity_days = 30
  }

  email_configuration {
      reply_to_email_address = "sebastien.lavayssiere@wescale.fr"
  }
}
