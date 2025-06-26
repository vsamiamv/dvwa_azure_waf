$resourceGroup = "dvwa-rg"
$agwPublicIP = "dvwa-agw-pip"
$agwsku = "WAF_v2"
$applicationGatewayName = "dvwa-agw"
$location = "eastus"
$vnet = "dvwa-vnet"
$subnetAGW = "subnet-agw"
# GET VM PRIVATE IP
$vmPrivateIP = az vm list-ip-addresses --resource-group $resourceGroup --name $vmName --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv
$wafPolicy = "dvwa-waf-policy"
$workspace = "waf-logs-workspace"
$diagnostic_logs = "diagnostic_logs"

az login

# create a public IP for the application gateway
az network application-gateway create `
    --resource-group $resourceGroup `
    --name $applicationGatewayName `
    --location $location `
    --sku $agwsku `
    --capacity 1 `
    --vnet-name $vnet `
    --subnet $subnetAGW `
    --public-ip-address $agwPublicIP `
    --frontend-port 80 `
    --http-settings-port 80 `
    --http-settings-protocol Http `
	--priority 100 `
	--servers $vmPrivateIP `
	--waf-policy $wafPolicy

# create a log analytics workspace and link to the diagnostic in the application gateway
az monitor log-analytics workspace create `
    --resource-group $resourceGroup `
    --workspace-name $workspace `
    --location $location
az monitor diagnostic-settings create `
    --name $diagnostic_logs `
    --resource $applicationGatewayName `
    --workspace $workspace `
    --logs '[{"category": "ApplicationGatewayAccessLog", "enabled": true}, {"category": "ApplicationGatewayPerformanceLog", "enabled": true}, {"category": "ApplicationGatewayFirewallLog", "enabled": true}]' `
    --metrics '[{"category": "AllMetrics", "enabled": true}]'



