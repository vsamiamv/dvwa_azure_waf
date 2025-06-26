$resourceGroup = "dvwa-rg"
$agwPublicIP = "dvwa-agw-pip"
$agwsku = "WAF_v2"
$applicationGatewayName = "dvwa-agw_v2"
$location = "eastus"
$vnet = "dvwa-vnet"
$subnetAGW = "subnet-agw"
# GET VM PRIVATE IP
$vmPrivateIP = az vm list-ip-addresses --resource-group $resourceGroup --name $vmName --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv
$wafPolicy = "dvwa-waf-policy"
$workspace = "waf-logs-v4"
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

# link to the diagnostic setting in the application gateway

az monitor diagnostic-settings create `
  --name $diagnostic_logs `
  --resource $(az network application-gateway show `
                --name $applicationGatewayName `
                --resource-group $resourceGroup `
                --query id -o tsv) `
  --workspace $workspace `
  --logs '[{"category":"ApplicationGatewayAccessLog","enabled":true},{"category":"ApplicationGatewayPerformanceLog","enabled":true},{"category":"ApplicationGatewayFirewallLog","enabled":true}]' `
  --metrics '[{"category":"AllMetrics","enabled":true}]'


$agwIP = az network public-ip show --resource-group $resourceGroup --name $agwPublicIP --query "ipAddress" -o tsv
Write-Host "DVWA will be accessible at: http://$agwIP/dvwa/setup.php"



