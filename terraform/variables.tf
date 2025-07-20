# variables.tf
# Define input variables for Terraform modules

# Example variable
variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "East US"
}

# Add more variables as needed for your infrastructure
