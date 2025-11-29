# 1. DATASOURCE: Отримання інформації про існуючу Resource Group
data "azurerm_resource_group" "existing" {
  name = var.rg_name
}

# 2. DATASOURCE: Отримання інформації про існуючий Virtual Network (VNet)
data "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# 3. DATASOURCE: Отримання інформації про існуючий Subnet
data "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.existing.name
}

# 4. DATASOURCE: Отримання інформації про існуючий Public IP
data "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# 5. DATASOURCE: Отримання інформації про існуючий Network Interface Card (NIC)
data "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# 6. DATASOURCE: Отримання інформації про існуючу Virtual Machine (VM)
data "azurerm_virtual_machine" "main" {
  name                = "${var.prefix}-vm"
  resource_group_name = data.azurerm_resource_group.existing.name
}