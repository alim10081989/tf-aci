data "azurerm_resource_group" "acr_rg" {
  name = var.resource_group_name
}

data "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = data.azurerm_resource_group.acr_rg.name
}

resource "random_pet" "container_name" {
  prefix = "aci"
}

resource "random_string" "container_name" {
  length  = 25
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "container-uami"
  location            = data.azurerm_resource_group.acr_rg.location
  resource_group_name = data.azurerm_resource_group.acr_rg.name
}

resource "azurerm_role_assignment" "acrpull_role" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

resource "azurerm_container_group" "container" {
  name                = "${var.container_group_name_prefix}-${random_string.container_name.result}"
  location            = data.azurerm_resource_group.acr_rg.location
  resource_group_name = data.azurerm_resource_group.acr_rg.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = var.restart_policy
  dns_name_label      = "${var.container_group_name_prefix}-${random_string.container_name.result}"
  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     azurerm_user_assigned_identity.managed_identity.id
  #   ]
  # }

  image_registry_credential {
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
    server   = data.azurerm_container_registry.acr.login_server
  }

  container {
    name   = "${var.container_name_prefix}-${random_string.container_name.result}"
    image  = "${data.azurerm_container_registry.acr.login_server}/azurewebapp:latest"
    cpu    = var.cpu_cores
    memory = var.memory_in_gb

    ports {
      port     = var.port
      protocol = "TCP"
    }
  }

   tags = {
    "Owner" = "Alim"
    "Purpose" = "Learning"
    "Type" = "ACI"
  }
}