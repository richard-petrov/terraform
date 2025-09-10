# --- Блок 1: Настройка Terraform и Провайдера ---
# Этот блок говорит Terraform, какой провайдер нам нужен и откуда его скачать.

terraform {
    required_providers {
        rabbitmq = {
            source  = "cyrilgdn/rabbitmq"
            version = "1.10.0"
        }
    }
}

# Здесь мы настраиваем подключение к нашему серверу RabbitMQ.
# Terraform будет использовать эти данные для входа, как если бы это был пользователь.

provider "rabbitmq" {
    endpoint = "http://localhost:15672" # Адрес API управления RabbitMQ
    username = "guest"                 # Используем стандартного пользователя
    password = "guest"                 # для управления
}

# --- Блок 2: Описание топологии RabbitMQ ---
# Давайте создадим нового пользователя специально для нашего приложения.
# Работать под 'guest' в реальных проектах - плохая практика.

resource "rabbitmq_user" "app_user" {
    name     = "py_app_user"
    password = "SuperSecretPassword123" # В реальных проектах пароль нужно выносить в переменные
    tags     = ["monitoring", "policymaker"]
}

# Создадим "виртуальный хост" (vhost). Это как отдельная песочница
# для нашего приложения внутри одного сервера RabbitMQ.

resource "rabbitmq_vhost" "app_vhost" {
    name = "app_vhost"
}

# Дадим нашему новому пользователю полные права на этот vhost.

resource "rabbitmq_permissions" "app_user_permissions" {
    user = rabbitmq_user.app_user.name
    vhost = rabbitmq_vhost.app_vhost.name
    permissions {
        configure = ".*"  # Разрешаем создавать и изменять объекты
        write     = ".*"  # Разрешаем отправлять сообщения
        read      = ".*"  # Разрешаем получать сообщения
    }
}

# Создадим обменник (exchange) типа 'fanout'.
# Он будет рассылать копии сообщения во все подключенные к нему очереди.

resource "rabbitmq_exchange" "main_exchange" {
    name  = "events_exchange"
    vhost = rabbitmq_vhost.app_vhost.name
    settings {
        type    = "fanout"
        durable = true
    }
}

# Создадим первую очередь для обработки событий.

resource "rabbitmq_queue" "task_queue_1" {
    name = "processing_queue_1"
    vhost = rabbitmq_vhost.app_vhost.name
    settings {
        durable = true
    }
}

# Создадим вторую очередь, например, для логирования.

resource "rabbitmq_queue" "task_queue_2" {
    name = "logging_queue_1"
    vhost = rabbitmq_vhost.app_vhost.name
    settings {
        durable = true
    }
}

# --- Блок 3: Связывание (Bindings) ---
# Теперь свяжем наши очереди с обменником. Это самый важный шаг
# для создания топологии.

resource "rabbitmq_binding" "binding_1" {
    source = rabbitmq_exchange.main_exchange.name
    vhost  = rabbitmq_vhost.app_vhost.name
    destination = rabbitmq_queue.task_queue_1.name
    destination_type = "queue"
}

# Привязываем вторую очередь к тому же обменнику
resource "rabbitmq_binding" "binding2" {
  source      = rabbitmq_exchange.main_exchange.name
  vhost       = rabbitmq_vhost.app_vhost.name
  destination = rabbitmq_queue.task_queue_2.name
  destination_type = "queue"
}