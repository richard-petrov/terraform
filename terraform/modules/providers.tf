/*
Файл - указатель провайдеров и их.
В нашем случае это rabbitmq, random и vault
*/

terraform {
    required_providers {
        rabbitmq = {
            endpoint = ""
            username = ""
            password = ""
        }
        /*
        vault = {
            source  = "hasicorp/vault"
            version = "3.24.0"
        }
        random = {
            source  = "hasicorp/vault"
            version = "3.6.3"
        }
        */
    }
    backend "consul" {
    address = "172.24.25.231:8500" # IP-адрес сервера Terraform state
    datacenter = "dc1"
    path = "\\ocs.ru\adm\PolyAnalyst\DATA\python_code\users\rpetrov\terraform\state_info" # Путь, по которому будет храниться state-файл
  }
}