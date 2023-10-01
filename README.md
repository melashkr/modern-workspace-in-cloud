# modern-workspace-in-cloud


## developer vm with terraform
That are the basic commands to initialize, plan, and apply configurations with Terraform as follows:

**Initialization**: This command prepares your working directory for other Terraform commands, downloading the necessary provider plugins.  
cmd: terraform init

**Planning**: This command shows you what Terraform will do before actually making any changes. It's a way to see what changes will be made without applying them.  
cmd: terraform plan

**Applying with Enforcement**: The apply command is used to apply the changes required to reach the desired state  
terraform apply -auto-approve

**Deploy Bicep**

// 
cmd: az deployment group create --what-if  --resource-group rg-poc-vmwithpowerapp --template-file .\dev-vm-01.bicep --parameters .\dev-vm-01.parameters.json

// generate arm from bicep
cmd: bicep build .\dev-vm-01.bicep

// generate bicep from arm-template
cmd: bicep decompile .\dev-vm-01.json