######################## GENERAL ########################

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
}

/*   ####### if it's necessary

resource "azurerm_log_analytics_workspace" "main" {
  location            = coalesce(var.log_analytics_workspace_location, local.resource_group.location)
  name                = "prefix-workspace"
  resource_group_name = local.resource_group.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "main" {
  location              = coalesce(var.log_analytics_workspace_location, local.resource_group.location)
  resource_group_name   = local.resource_group.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.main.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

*/

###################### Networking ########################


resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-${var.environment}-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "service" {
  name                 = "${var.prefix}-${var.environment}-service-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "apps" {
  name                 = "${var.prefix}-${var.environment}-apps-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "${var.prefix}-${var.environment}-gateway-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["192.168.3.0/27"]
}


resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-${var.environment}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


######################## AGIC ###################
/* locals {
  backend_address_pool_name      = "${azurerm_virtual_network.main.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.main.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.main.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.main.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.main.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.main.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.main.name}-rdrcfg"
}

resource "azurerm_application_gateway" "main" {
  ##firewall_policy_id                = "/subscriptions/132d9c6b-55d1-475d-bd5e-d3f86b54c8de/resourceGroups/Security/providers/Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/OWASP_3.2_Custom-Rule-for-AKS"
  ##force_firewall_policy_association = true
  name                = "${var.prefix}-agic"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags = {
    Environment = var.environment
  }

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.service.id  #### check correct subnet
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.main.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  
  frontend_port {
    name = "${local.frontend_port_name}-https"
    port = 443
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    ##path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  request_routing_rule {
   ## count                      = length(azurerm_application_gateway.main.http_listener)
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 20000
  }

  /*
  waf_configuration {
    enabled          = true
    firewall_mode    = "Detection"
    rule_set_version = "3.0"
    exclusion {
      match_variable          = "RequestCookieNames"
      selector                = "ui"
      selector_match_operator = "Equals"
    }
  }
  depends_on = [
     azurerm_virtual_network.main,
     azurerm_public_ip.main
  ]
}*/


############################### AKS #######################

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.prefix}-${var.environment}-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.prefix}-${var.environment}-aks-dns"
  oidc_issuer_enabled =  true
  role_based_access_control_enabled = true

  /*ingress_application_gateway {
    gateway_name = "${var.prefix}-agic"
    subnet_cidr = "10.200.1.0/24"
  }*/

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }
  
  /*service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }*/
  
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
    enable_auto_scaling = true
    max_count           = 2
    min_count           = 1
    vnet_subnet_id      = azurerm_subnet.apps.id
  }

  /*linux_profile {
    admin_username = "${var.prefix}-ssh-key"
    ssh_key {
      key_data = "${file("~/.ssh/id_rsa.pub")}"  
    }
  }*/## check private with team
  
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = {
    Environment = var.environment
  }


}

####################### Identity ###################

resource "azurerm_user_assigned_identity" "main" {
  location            = var.location
  name                = "${var.prefix}-${var.environment}-msi"
  resource_group_name = azurerm_resource_group.main.name
}
/*
resource "azurerm_role_assignment" "ra1" {
  scope                = azurerm_subnet.apps.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id

  depends_on = [azurerm_virtual_network.main]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.main.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
  depends_on           = [azurerm_user_assigned_identity.main]
}

resource "azurerm_role_assignment" "ra4" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
  depends_on           = [azurerm_user_assigned_identity.main]
}


resource "azurerm_role_assignment" "main" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
  depends_on           = [azurerm_user_assigned_identity.main]
} 
*/
############### ACR #################

resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}${var.environment}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  tags = {
    Environment = var.environment
  }
}

####################### Storage ###################

resource "azurerm_storage_account" "main" {
  name                     = "${var.prefix}${var.environment}sa"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
 /* identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.default.id]
  }*/
  tags = {
    environment = "${var.environment}"
  }
}

######################## AKV ######################

resource "azurerm_key_vault" "main" {
  name                        = "${var.prefix}-${var.environment}-kv"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = "ce67aede-9a8e-4810-993a-395b1e08e530"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
 # enable_rbac_authorization   = true  |to apply in production

  sku_name = "standard"
  
  access_policy {
    tenant_id = "ce67aede-9a8e-4810-993a-395b1e08e530"
    object_id = "0e9cb019-0f53-4dba-96f1-cd3e2a565381"

    key_permissions = [
      "Get","Create","List"
    ]

    secret_permissions = [
      "Get","Set","List"
    ]

    storage_permissions = [
      "Get","Set","List"
    ]
  }

  access_policy {
    tenant_id = "ce67aede-9a8e-4810-993a-395b1e08e530"
    object_id = "4c671bca-e8d4-4c6c-91c1-f76e3372d6a5"

    key_permissions = [
      "Get","Create","List"
    ]

    secret_permissions = [
      "Get","Set","List"
    ]

    storage_permissions = [
      "Get","Set","List"
    ]
  }

}

