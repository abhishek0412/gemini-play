# gemini-play

A comprehensive project combining .NET application development with Infrastructure as Code (IaC) and automation tools. This repository demonstrates modern DevOps practices using multiple technologies for both application development and infrastructure management.

## 🏗️ Project Structure

```
gemini-play/
├── Program.cs              # .NET console application entry point
├── gemini-play.csproj      # .NET project file
├── ansible/                # Ansible automation playbooks
│   └── roles/             # Infrastructure automation roles
│       ├── cache/         # Cache server configuration
│       ├── db/            # Database setup and management
│       ├── eks/           # Amazon EKS cluster management
│       ├── load_balancer/ # Load balancer configuration
│       ├── storage/       # Storage solutions setup
│       └── windows/       # Windows server management
├── bicep/                 # Azure Bicep templates
│   └── network.bicep      # Network infrastructure template
└── terraform/             # Terraform IaC templates
    └── main.tf            # Main Terraform configuration
```

## 🚀 Getting Started

### Prerequisites

#### For .NET Application:
*   [.NET SDK](https://dotnet.microsoft.com/download) (6.0 or later)

#### For Infrastructure Automation:
*   [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
*   [Terraform](https://developer.hashicorp.com/terraform/downloads)
*   [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Bicep)
*   [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

### Installation

1.  Clone the repository
    ```sh
    git clone https://github.com/abhishek0412/gemini-play.git
    ```
2.  Navigate to the project directory
    ```sh
    cd gemini-play
    ```

## 💻 Usage

### .NET Application

To run the .NET console application:

```sh
dotnet run
```

### Infrastructure Automation

#### Using Ansible
```sh
# Run specific roles
ansible-playbook -i inventory ansible/playbook.yml --tags cache
ansible-playbook -i inventory ansible/playbook.yml --tags database
```

#### Using Terraform
```sh
cd terraform/
terraform init
terraform plan
terraform apply
```

#### Using Azure Bicep
```sh
cd bicep/
az deployment group create --resource-group myResourceGroup --template-file network.bicep
```

## 🛠️ Technologies Used

- **.NET**: Console application development
- **Ansible**: Configuration management and automation
- **Terraform**: Infrastructure as Code for multi-cloud deployments
- **Azure Bicep**: Azure-native Infrastructure as Code
- **Git**: Version control and collaboration

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

