output "address" {
    value = module.mysql.address
    description = "Connection address for the database"
}

output "port" {
    value = module.mysql.port
    description = "The port the database if lestening on"
}
