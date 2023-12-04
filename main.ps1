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

# --- Authenticate to vCenter and Tag VM
Connect-VIserver $vCenterServer -User $vCenterUsername -Password $vCenterPassword
$tag = Get-Tag "revoked"

# --- Check view to see if image is a Template or Virtual Machine
try { $VMView = Get-View -ViewType VirtualMachine -Filter @{"Name"=$VMName} 

  switch ($VMView.Config.Template) {
    $false { Get-VM -Name $VMName | New-TagAssignment -Tag $tag } #| Remove-VM -confirm:$false -ErrorAction SilentlyContinue }
    $true { Get-Template -Name $VMName | New-TagAssignment -Tag $tag } # | Remove-Template -confirm:$false -ErrorAction SilentlyContinue }
  }
}

catch { 
  Write-Host "No matching Virtual Machine or Template found with name $VMName."
}
