# Топология проекта fill_lefts
module "fill_lefts_tolology" {
    source = "./modules/topology/templates"

    # Настройка Direct Exchange
    create_direct_exchange = true
    direct_name = "fill_lefts_exchange"

    # Настройка очередей
    queue_count = 1
    queue_name_prefix = "fill_lefts"

    # Общие настройки
    vhost_name = var.vhost_name
    durable = true
    sac_needed = true
}