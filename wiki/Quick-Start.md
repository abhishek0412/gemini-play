# Quick Start Guide

Get up and running with **gemini-play** in just 5 minutes! This guide will help you set up the development environment and deploy your first infrastructure components.

## 🚀 Prerequisites

Before you begin, ensure you have the following tools installed:

- **Git** - Version control
- **.NET SDK 8.0+** - For the application
- **Azure CLI** - For Azure authentication
- **Terraform** - For infrastructure deployment
- **jq** - For JSON processing (compliance checks)

### Quick Installation (macOS)

```bash
# Install via Homebrew
brew install git dotnet azure-cli terraform jq

# Verify installations
git --version
dotnet --version
az --version
terraform --version
jq --version
```

### Quick Installation (Windows)

```powershell
# Install via Chocolatey
choco install git dotnetcore-sdk azure-cli terraform jq

# Or use winget
winget install Git.Git Microsoft.DotNet.SDK.8 Microsoft.AzureCLI HashiCorp.Terraform jqlang.jq
```

## 📥 Step 1: Clone the Repository

```bash
git clone https://github.com/abhishek0412/gemini-play.git
cd gemini-play
```

## 🔐 Step 2: Authentication Setup

### Azure Authentication
```bash
# Login to Azure
az login

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

## 🏃‍♂️ Step 3: Run the Application

```bash
# Run the .NET console application
dotnet run

# Expected output: "Hello from gemini-play!"
```

## 🏗️ Step 4: Deploy Infrastructure (Optional)

### Option A: Deploy with Terraform

```bash
# Navigate to Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the infrastructure (creates Azure Resource Group and Storage Account)
terraform apply

# Clean up when done
terraform destroy
```

### Option B: Deploy with Bicep

```bash
# Navigate to Bicep directory
cd bicep

# Create a resource group first
az group create --name gemini-play-rg --location "East US"

# Deploy the Bicep template
az deployment group create \
  --resource-group gemini-play-rg \
  --template-file network.bicep

# Clean up when done
az group delete --name gemini-play-rg --yes --no-wait
```

## ✅ Step 5: Run Compliance Checks

```bash
# Run all compliance checks
./compliance/scripts/compliance-checker.sh

# View the compliance report
ls -la compliance/reports/

# Check specific policy
./compliance/scripts/compliance-checker.sh --policy security
```

## 📊 Step 6: Verify Your Setup

Run this verification script to ensure everything is working:

```bash
# Create a simple verification script
cat > verify-setup.sh << 'EOF'
#!/bin/bash
echo "🔍 Verifying gemini-play setup..."

# Check .NET application
echo "✅ Testing .NET application..."
dotnet run --project . | grep -q "Hello from gemini-play!" && echo "  ✅ .NET app works" || echo "  ❌ .NET app failed"

# Check Terraform
echo "✅ Testing Terraform configuration..."
cd terraform && terraform validate && echo "  ✅ Terraform config valid" || echo "  ❌ Terraform config invalid"
cd ..

# Check Bicep
echo "✅ Testing Bicep template..."
az bicep build --file bicep/network.bicep > /dev/null 2>&1 && echo "  ✅ Bicep template valid" || echo "  ❌ Bicep template invalid"

# Check compliance framework
echo "✅ Testing compliance framework..."
./compliance/scripts/compliance-checker.sh > /dev/null 2>&1 && echo "  ✅ Compliance checks work" || echo "  ⚠️ Compliance checks have findings (normal)"

echo "🎉 Setup verification complete!"
EOF

chmod +x verify-setup.sh
./verify-setup.sh
```

## 🎯 Next Steps

Now that you have the basic setup running, explore these areas:

1. **[[Infrastructure Deployment|Deployment]]** - Learn about production deployment strategies
2. **[[Compliance Framework|Compliance-Framework]]** - Deep dive into policy-as-code
3. **[[Development Guide|Local-Development]]** - Set up your development environment
4. **[[Ansible Configuration|Ansible]]** - Explore configuration management
5. **[[Best Practices|Best-Practices]]** - Learn recommended patterns

## 🆘 Troubleshooting

### Common Issues

**Issue**: Terraform authentication errors
```bash
# Solution: Re-authenticate with Azure
az logout
az login
```

**Issue**: .NET application won't run
```bash
# Solution: Verify SDK version
dotnet --version
# Should be 8.0 or higher
```

**Issue**: Compliance checks fail
```bash
# Solution: Install jq if missing
brew install jq  # macOS
choco install jq  # Windows
```

**Issue**: Permission denied on compliance scripts
```bash
# Solution: Make scripts executable
chmod +x compliance/scripts/*.sh
```

For more detailed troubleshooting, see **[[Troubleshooting|Troubleshooting]]**.

## 💡 Tips for Success

- **Start Small**: Deploy one component at a time
- **Use Version Control**: Commit changes frequently
- **Monitor Costs**: Keep an eye on Azure resource usage
- **Follow Compliance**: Run compliance checks before deployments
- **Document Changes**: Update the wiki with your modifications

## 📚 What's Next?

- Explore the **[[Terraform Guide|Terraform]]** for advanced infrastructure patterns
- Check out **[[Security Policies|Security-Policies]]** for compliance requirements
- Learn about **[[CI/CD Pipeline|CICD]]** for automated deployments

---

*Need help? Check our **[[Troubleshooting|Troubleshooting]]** guide or open an issue on GitHub!*
