# Proyecto de Infraestructura como Código con Terraform

Este proyecto utiliza Terraform para provisionar recursos en Azure. Los recursos incluyen grupos de recursos, redes virtuales, subredes, IP públicas, identidades de usuario asignadas, clústeres de Kubernetes (AKS), registros de contenedores (ACR), cuentas de almacenamiento y almacenes de claves (AKV).

## Descripcion

Usando Terraform y AKS (Azure Kubernetes Service) podemos generar una infraestructura rapida y escalable para un continuo despliegue y continua integracion del proyecto MMRV.

## instrucciones de uso

* Asegurate de modificar SOLO las variables "var.prefix", "var.environment", "var.location" en el archivo `variables.tf` segun las necesidades de tu proyecto. ""aks_service_cidr","aks_dns_service_ip","username" por defecto


run `terraform init`

run `terraform plan`

run `terraform apply`

## precondiciones

tener las credencial de tu portal azure:
* subscription_id
* tenant_id 
* client_id                  
* client_secret 

**para Mac installar paqueteria homebrew

## Recursos


### Grupos de Recursos
Se crea un grupo de recursos con el nombre formado por el prefijo, el entorno y el sufijo "rg".

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
}

### Redes Virtuales y Subredes
Se crea una red virtual y varias subredes dentro de ella. Los nombres de estos recursos también se forman a partir del prefijo y el entorno.

resource "azurerm_virtual_network" "main" {
  ...
}

resource "azurerm_subnet" "service" {
  ...
}

resource "azurerm_subnet" "apps" {
  ...
}

resource "azurerm_subnet" "gateway" {
  ...
}

### IP Pública
Se crea una IP pública con el método de asignación estática.

resource "azurerm_public_ip" "main" {
  ...
}

### Identidad de Usuario Asignada
Se crea una identidad de usuario asignada para la gestión de identidades y accesos.

resource "azurerm_user_assigned_identity" "main" {
  ...
}

### Clúster de Kubernetes (AKS)
Se crea un clúster de Kubernetes con un grupo de nodos por defecto. La identidad del clúster se establece en la identidad de usuario asignada creada anteriormente.

resource "azurerm_kubernetes_cluster" "main" {
  ...
}

### Registro de Contenedores (ACR)
Se crea un registro de contenedores para almacenar imágenes de contenedores.

resource "azurerm_container_registry" "main" {
  ...
}

### Cuenta de Almacenamiento
Se crea una cuenta de almacenamiento para almacenar y recuperar grandes cantidades de datos no estructurados.

resource "azurerm_storage_account" "main" {
  ...
}

### Almacén de Claves (AKV)
Se crea un almacén de claves para salvaguardar las claves criptográficas y otros secretos utilizados por los servicios de la nube.

resource "azurerm_key_vault" "main" {
  ...
}

## Outputs

`resource_group_name`
El nombre del grupo de recursos creado.

`client_key`
La clave del cliente para el clúster de Kubernetes. Esta clave es sensible y se maneja como tal por Terraform.

`client_certificate`
El certificado del cliente para el clúster de Kubernetes. Este certificado es sensible y se maneja como tal por Terraform.

`cluster_ca_certificate`
El certificado CA del clúster de Kubernetes. Este certificado es sensible y se maneja como tal por Terraform.

`cluster_username`
El nombre de usuario para el clúster de Kubernetes. Este nombre de usuario es sensible y se maneja como tal por Terraform.

`cluster_password`
La contraseña para el clúster de Kubernetes. Esta contraseña es sensible y se maneja como tal por Terraform.

`kube_config`
La configuración completa de kubectl para el clúster de Kubernetes. Esta configuración es sensible y se maneja como tal por Terraform.

`host`
El host para el clúster de Kubernetes. Este host es sensible y se maneja como tal por Terraform.

`identity_resource_id`
El ID de recurso de la identidad de usuario asignada.

`identity_client_id`
El ID de cliente de la identidad de usuario asignada.

`application_ip_address`
La dirección IP de la aplicación.

`secret_identity_AKV`
La identidad secreta para el proveedor de secretos del almacén de claves de Azure.

## Versions

| Version | Major changes |
| ------- | ------------- |
| 1     | creacion de modulo |
\
