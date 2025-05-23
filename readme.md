# DVWA Azure Deployment

This project provides scripts to deploy DVWA (Damn Vulnerable Web Application) an Application Gateway and a WAF Policy on Azure using PowerShell and Azure CLI.

## Prerequisites

- A valid Azure account with an active subscription.
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- PowerShell installed.
- All deployment files (`deploy_dvwa.ps1`, `deploy_agw.ps1`, and any referenced files) must be in the same directory.

## Deployment Steps

1. **Customize Variables (Optional):**
   - Open `deploy_dvwa.ps1` and `deploy_agw.ps1`.
   - Edit the variable values at the top of each script to match your Azure environment and preferences.
   - The username and password for DVWA are the defaults if you change them in the "dvwa-cloud-init.txt" file you will need to ssh to the machine and update the  /var/www/html/dvwa/config/config.inc.php file.

2. **Run the Deployment Scripts:**
   - Open a PowerShell terminal.
   - Navigate to the directory containing the scripts.
   - Run the following commands in order:

     ```powershell
     ./deploy_dvwa.ps1
     ./deploy_agw.ps1
     ```

3. **Access DVWA:**
   - After deployment, follow the output instructions to access your DVWA instance.

## Notes

- Ensure you are logged in to Azure CLI before running the scripts (`az login`).
- You can modify the variable names and values in the scripts to suit your requirements.
- The scripts will create and configure all necessary Azure resources.
- You will need to enable the waf policy after creation since the policy is created in the disabled state.

---
