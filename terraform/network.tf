# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.project}-${var.environment}"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Subnets
resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_prefixes[count.index]]

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
}

# Network Security Groups
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range         = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# DDoS Protection Plan
resource "azurerm_network_ddos_protection_plan" "main" {
  name                = "ddos-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# Azure Firewall
resource "azurerm_firewall" "main" {
  name                = "fw-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.subnets[0].id
    public_ip_address_id = azurerm_public_ip.fw.id
  }
}

# Public IP for Firewall
resource "azurerm_public_ip" "fw" {
  name                = "pip-fw-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnets[1].id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.agw.id
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-backend-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol             = "Https"
    request_timeout      = 60
  }

  http_listener {
    name                           = "default-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name            = "https-port"
    protocol                      = "Https"
  }

  request_routing_rule {
    name                       = "default-routing-rule"
    rule_type                 = "Basic"
    http_listener_name        = "default-listener"
    backend_address_pool_name = "default-backend-pool"
    backend_http_settings_name = "default-backend-settings"
    priority                  = 100
  }

  waf_configuration {
    enabled                  = true
    firewall_mode           = "Prevention"
    rule_set_type          = "OWASP"
    rule_set_version       = "3.2"
    file_upload_limit_mb   = 100
    max_request_body_size_kb = 128
  }
}

# Public IP for Application Gateway
resource "azurerm_public_ip" "agw" {
  name                = "pip-agw-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  sku                = "Standard"
}