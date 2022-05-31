# Install the MSOnline module if this is first use
Install-Module MSOnline
# Add the MSOnline module to the PowerShell session
Import-Module MSOnline
# Get credentials of Azure admin
#$Credentials = Get-Credential
# Connect to Azure AD
#Connect-MsolService -Credential $Credentials