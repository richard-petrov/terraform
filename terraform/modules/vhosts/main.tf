resource "rabbitmq_vhost" "vhost"
{  
  for_each = toset(var.vhosts) 
  name     = each.key  
}