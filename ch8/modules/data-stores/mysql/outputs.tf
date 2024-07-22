output "address" {
    value = aws_db_instance.example.address
    description = "Connection address for the database"
}

output "port" {
    value = aws_db_instance.example.port
    description = "The port the database if lestening on"
}
