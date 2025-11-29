variable "prefix" {
  description = "Префікс для унікальності імен ресурсів"
  default     = "tf-nginx-final"
}

variable "rg_name" {
  description = "Ім'я вручну створеної Resource Group"
  # Використовуємо ім'я, яке ви створили:
  default = "nginx-hosting-rg"
}

variable "admin_username" {
  default = "testadmin"
}

variable "admin_password" {
  default   = "Password1234!"
  sensitive = true
}