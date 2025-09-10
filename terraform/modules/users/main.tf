resource "random_password" "genpass" {
  for_each = toset(var.usernames)
  length           = 20             # Длина пароля (20 символов)
  special          = true           # Включает спецсимволы
  override_special = "!№*"          # Разрешенные спецсимволы
}
 
resource "vault_generic_secret" "write_creds" {
  for_each = toset(var.usernames)
  path = "iac/rabbitmq-ba-devops/users/${each.key}"
 
  data_json = <<EOT
  {
      "username": "${each.key}",
      "password": "${random_password.genpass[each.key].result}"
  }
  EOT
}
 
resource "rabbitmq_user" "user" {
  for_each = toset(var.usernames)
  name     = each.key
  password = random_password.genpass[each.key].result
}