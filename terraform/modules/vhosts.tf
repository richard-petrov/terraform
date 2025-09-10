/*
Вызов модуля vhost
*/

module "vhosts" {
    source = "./modules/vhosts"
    vhosts = [
        "/test",
        "/fill_lefts"
    ]
}