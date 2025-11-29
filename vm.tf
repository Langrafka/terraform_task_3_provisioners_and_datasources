# Використовуємо null_resource для виконання provisioners
# Provisioners не можуть бути прикріплені до Data Sources (VM), тому використовуємо цей підхід.
resource "null_resource" "nginx_config" {
  # Trigger змушує null_resource виконувати provisioners при зміні ID VM
  triggers = {
    vm_id = data.azurerm_virtual_machine.main.id
  }

  # 1. FILE PROVISIONER: Копіює локальний index.html
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      # Використовуємо IP-адресу, отриману з Data Source Public IP
      host     = data.azurerm_public_ip.main.ip_address 
      timeout  = "5m"
    }
  }

  # 2. REMOTE-EXEC PROVISIONER: Встановлює Nginx та налаштовує сторінку
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = data.azurerm_public_ip.main.ip_address
      timeout  = "5m"
    }

    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      # Виправлення шляху на /var/www/html/index.html (вимога ментора)
      "sudo cp /tmp/index.html /var/www/html/index.html", 
      "sudo systemctl restart nginx",
    ]
  }
}

# OUTPUT: Виводить публічну IP-адресу для перевірки
output "nginx_public_ip" {
  description = "Публічна IP-адреса для доступу до веб-сервера Nginx"
  # Використовуємо Data Source Public IP
  value       = data.azurerm_public_ip.main.ip_address
}