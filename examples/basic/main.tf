provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-container-app-example"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-container-app-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-container-app"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/21"]

  delegation {
    name = "container-app-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-container-app-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "container_app_environment" {
  source = "../../"

  name                       = "cae-example-basic"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  infrastructure_subnet_id   = azurerm_subnet.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "Example"
    Purpose     = "BasicDemo"
  }
}

output "container_app_environment_id" {
  value = module.container_app_environment.id
}

output "container_app_environment_default_domain" {
  value = module.container_app_environment.default_domain
}

output "container_app_environment_static_ip" {
  value = module.container_app_environment.static_ip_address
}
