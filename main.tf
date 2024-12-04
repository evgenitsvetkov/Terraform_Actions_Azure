terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.12.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ae8b7411-0eb2-4585-a662-ce0b11f3ae7f"
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "taskboardResourceGroup" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "azurerm_service_plan" "taskboardappsp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.taskboardResourceGroup.name
  location            = azurerm_resource_group.taskboardResourceGroup.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "taskboardevgeni" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.taskboardResourceGroup.name
  location            = azurerm_service_plan.taskboardappsp.location
  service_plan_id     = azurerm_service_plan.taskboardappsp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.evgenisqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.evgenidb.name};User ID=${azurerm_mssql_server.evgenisqlserver.administrator_login};Password=${azurerm_mssql_server.evgenisqlserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_app_service_source_control" "evgenigithub" {
  app_id                 = azurerm_linux_web_app.taskboardevgeni.id
  repo_url               = var.repo_URL
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "evgenisqlserver" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.taskboardResourceGroup.name
  location                     = azurerm_resource_group.taskboardResourceGroup.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "evgenidb" {
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.evgenisqlserver.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
  depends_on     = [azurerm_mssql_server.evgenisqlserver]
}

resource "azurerm_mssql_firewall_rule" "evgenifirewall" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.evgenisqlserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}