# --- Source Environment Variables
$ClientId = $env:HCP_CLIENT_ID
$ClientSecret = $env:HCP_CLIENT_SECRET
$OrgId = $env:HCP_ORG_ID
$ProjectId = $env:HCP_PROJECT_ID
$BucketSlug = $env:BUCKET_SLUG
$IterationId = $env:ITERATION_ID
$vCenterUsername = $env:VCENTER_USERNAME
$vCenterPassword = $env:VCENTER_PASSWORD
$vCenterServer = $env:VCENTER_SERVER
$VMName = $env:IMAGE_NAME

Write-Host "PSModulePath: " $env:PSModulePath

# --- Import Modules
$Modules = $(
  "Connect-HCP.ps1";
  "Get-HCPPackerIterationBuilds.ps1";
  "Invoke-HCPRestMethod.ps1"
)

foreach ($Module in $Modules) {
  Import-Module "./$Module" -Force
}

# --- Get Revoked Image Data
Write-Host -ForegroundColor Green -NoNewline "Connecting to HashiCorp Cloud Platform..."

$SecureClientSecret = ConvertTo-SecureString $ClientSecret -AsPlainText
Connect-HCP -ClientId $ClientId -ClientSecret $SecureClientSecret -OrgId $OrgId -ProjectId $ProjectId

Write-Host  -ForegroundColor Green "Finding revoked image name."

$VMName = Get-HCPPackerIterationBuilds -BucketSlug $BucketSlug -IterationId $IterationId | Select-Object -Expand Images | Select-Object -ExpandProperty ImageId
#$VMId = Get-HCPPackerIterationBuilds -BucketSlug $BucketSlug -IterationId $IterationId | Select-Object -Expand Images | Select-Object -ExpandProperty Id

# --- Authenticate to vCenter and Delete VM
Write-Host -ForegroundColor Green "Deleting template $VMName..."
Connect-VIserver $vCenterServer -User $vCenterUsername -Password $vCenterPassword

# --- Check view to see if image is a Template or Virtual Machine
$VMView = Get-View -ViewType VirtualMachine -Filter @{"Name"=$VMName} 

# --- Cleanup image
switch ($VMView.Config.Template) {
  $false {Get-VM -Name $VMName | Remove-VM -ErrorAction SilentlyContinue }
  $true {Get-Template -Name $VMName | Remove-Template -ErrorAction SilentlyContinue }
  Default {
    "No matching images found."
  }
}

 
