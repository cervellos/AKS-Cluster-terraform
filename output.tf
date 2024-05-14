output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "client_key" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_key
  sensitive = true
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
sensitive = true
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.username
  sensitive = true
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.password
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive = true
}

output "identity_resource_id" {
  value = azurerm_user_assigned_identity.main.id
}

output "identity_client_id" {
  value = azurerm_user_assigned_identity.main.client_id
}

output "application_ip_address" {
  value = azurerm_public_ip.main.ip_address
}

output "secret_identity_AKV" {
  value = azurerm_kubernetes_cluster.main.key_vault_secrets_provider.0.secret_identity
  
}