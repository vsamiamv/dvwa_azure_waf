# Set variables
$resourceGroup = "dvwa-rg"
$location = "eastus"
$vnet = "dvwa-vnet"
$vmName = "dvwa-vm"
$username = "azureuser"
$subnetVM = "subnet-vm"
$subnetAGW = "subnet-agw"
$nsg = "dvwa-nsg"
$agwPublicIP = "dvwa-agw-pip"
$publicIpSku = "Standard"
$publicIpAllocationMethod = "Static"
$applicationGatewayName = "dvwa-agw"
$wafPolicy = "dvwa-waf-policy"
$workspace = "waf-logs-v4"
$customDataFile = "dvwa-cloud-init.txt"

# LOGIN
az login

# Create resource group
az group create --name $resourceGroup --location $location

# CREATE LOG ANALYTICS WORKSPACE
az monitor log-analytics workspace create `
  --resource-group $resourceGroup `
  --workspace-name $workspace `
  --location $location

# CREATE VNET AND SUBNETS
az network vnet create `
  --resource-group $resourceGroup `
  --location $location `
  --name $vnet `
  --address-prefix 10.0.0.0/16 `
  --subnet-name $subnetVM `
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create `
  --resource-group $resourceGroup `
  --vnet-name $vnet `
  --name $subnetAGW `
  --address-prefix 10.0.2.0/24

# CREATE NSG
# =============================
az network nsg create --resource-group $resourceGroup --name $nsg

az network nsg rule create `
  --resource-group $resourceGroup `
  --nsg-name $nsg `
  --name AllowHTTP `
  --priority 100 `
  --access Allow `
  --direction Inbound `
  --protocol Tcp `
  --source-address-prefix "*" `
  --source-port-range "*" `
  --destination-port-ranges 80 `
  --destination-address-prefix "*"

az network nsg rule create `
  --resource-group $resourceGroup `
  --nsg-name $nsg `
  --name AllowHighPorts `
  --priority 110 `
  --access Allow `
  --direction Inbound `
  --protocol Tcp `
  --source-address-prefix "*" `
  --source-port-range "*" `
  --destination-port-ranges 65200-65535 `
  --destination-address-prefix "*"


# CREATE UBUNTU VM WITH SSH
# =============================
az vm create `
  --resource-group $resourceGroup `
  --name $vmName `
  --image Ubuntu2204 `
  --size Standard_B1s `
  --admin-username $username `
  --generate-ssh-keys `
  --custom-data $customDataFile

# GET VM PRIVATE IP
$vmPrivateIP = az vm list-ip-addresses --resource-group $resourceGroup --name $vmName --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv

# CREATE WAF POLICY
az network application-gateway waf-policy create --resource-group $resourceGroup --name $wafPolicy --location $location

# Create public IP address
az network public-ip create `
    --resource-group $resourceGroup `
    --name $agwPublicIP `
    --sku $publicIpSku `
    --allocation-method $publicIpAllocationMethod `
    --location $location

	
az network vnet subnet update `
  --resource-group $resourceGroup `
  --vnet-name $vnet `
  --name $subnetAGW `
  --network-security-group $nsg


# OUTPUT FINAL PUBLIC IP
# =============================
$agwIP = az network public-ip show --resource-group $resourceGroup --name $agwPublicIP --query "ipAddress" -o tsv
Write-Host "DVWA will be accessible after running the agw_deploy.ps1 script at: http://$agwIP/dvwa/setup.php"
