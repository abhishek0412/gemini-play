# outputs.tf
# Define outputs for Terraform modules

# Example output
output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

# Add more outputs as needed for your infrastructure
