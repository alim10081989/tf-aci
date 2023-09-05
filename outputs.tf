output "resource_group_name" {
  value = data.azurerm_resource_group.acr_rg.name
}

output "container_registry_name" {
  value = data.azurerm_container_registry.acr.name
}

output "container_registry_login" {
  value = data.azurerm_container_registry.acr.login_server
}

output "container_ipv4_address" {
  value = azurerm_container_group.container.ip_address
}

output "contain_fqdn" {
  value = azurerm_container_group.container.fqdn
}