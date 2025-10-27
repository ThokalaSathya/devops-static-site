# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Create Azure Container Registry (ACR) - Using the minimal 'Basic' SKU
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic" # Lowest cost SKU
  admin_enabled       = true    # Enable admin user for easy access/re-push in the next step
}

# 3. Create Azure Kubernetes Service (AKS) - Minimal node count/size for cost saving
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name                = "agentpool"
    node_count          = 1             # Minimal node count
    vm_size             = "Standard_B2s" # Minimal cost VM size
    vnet_subnet_id      = null # Using default virtual network
  }

  identity {
    type = "SystemAssigned"
  }

  # Grant AKS cluster's managed identity AcrPull role to the ACR
  role_based_access_control_enabled = true
}

# Output the ACR login server and AKS name for the next steps (re-push, deployment)
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}