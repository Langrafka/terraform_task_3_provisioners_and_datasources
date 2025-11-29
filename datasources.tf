# 1. DATASOURCE: Отримання інформації про існуючу Resource Group
data "azurerm_resource_group" "existing" {
  name = var.rg_name
}

# 2. DATASOURCE: Отримання інформації про існуючий Virtual Network (VNet)
# ЗМІНА: Раніше був resource, тепер data
data "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# 3. DATASOURCE: Отримання інформації про існуючий Subnet
# ЗМІНА: Раніше був resource, тепер data
data "azurerm_subnet" "internal" {
  name                 = "internal"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_resource_group.existing.name
}