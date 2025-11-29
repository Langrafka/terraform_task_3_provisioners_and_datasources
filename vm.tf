# 1. PUBLIC IP: Створення публічної IP-адреси
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name
  allocation_method   = "Static"
  # ВИПРАВЛЕННЯ: Рекомендовано Standard
  sku = "Standard"
}

# 2. NETWORK SECURITY GROUP (NSG): Відкриваємо порти 22 (SSH) та 80 (HTTP)
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 3. NETWORK INTERFACE CARD (NIC)
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name = "testconfiguration1"
    # ЗМІНА: Використовуємо subnet_id з data-блоку
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# 4. Прив'язка NSG до NIC
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# 5. VIRTUAL MACHINE (VM)
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = data.azurerm_resource_group.existing.location
  resource_group_name   = data.azurerm_resource_group.existing.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }

  # 1. FILE PROVISIONER: Копіює локальний index.html
  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.main.ip_address
      timeout  = "5m"
    }
  }

  # 2. REMOTE-EXEC PROVISIONER: Встановлює Nginx та налаштовує сторінку
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = azurerm_public_ip.main.ip_address
      timeout  = "5m"
    }

    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      # ВИПРАВЛЕННЯ: Змінено шлях з index.nginx-debian.html на index.html
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl restart nginx",
    ]
  }
}

# OUTPUT: Виводить публічну IP-адресу для перевірки
output "nginx_public_ip" {
  description = "Публічна IP-адреса для доступу до веб-сервера Nginx"
  value       = azurerm_public_ip.main.ip_address
}