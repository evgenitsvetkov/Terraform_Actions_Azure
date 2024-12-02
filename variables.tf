variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "The location of the resource group in Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the app's service plan in Azure"
}

variable "app_service_name" {
  type        = string
  description = "The name of the app's service in Azure"
}

variable "sql_server_name" {
  type        = string
  description = "The name of the sql server in Azure"
}

variable "sql_database_name" {
  type        = string
  description = "The name of the sql database in Azure"
}

variable "sql_admin_login" {
  type        = string
  description = "The username of the admin in Azure"
}

variable "sql_admin_password" {
  type        = string
  description = "The password of the admin in Azure"
}

variable "firewall_rule_name" {
  type        = string
  description = "The name of the firewall rule in Azure"
}

variable "repo_URL" {
  type        = string
  description = "The url of the app's repository in Azure"
}