resource "rabbitmq_exchange" "direct_master" {
    count = var.create_direct_exchange ? 1 : 0
    name  = var.direct_name
}