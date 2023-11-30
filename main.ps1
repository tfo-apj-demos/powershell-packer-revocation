# --- Source Environment Variables
$ClientId = $env:HCP_CLIENT_ID
$ClientSecret = $env:HCP_CLIENT_SECRET
$OrgId = $env:HCP_ORG_ID
$ProjectId = $env:HCP_PROJECT_ID
$vCenterUsername = $env:VCENTER_USERNAME
$vCenterPassword = $env:VCENTER_PASSWORD
$vCenterServer = $env:VCENTER_SERVER

# --- Import Modules
$Modules = $(
  "Connect-HCP.ps1";
  "Get-HCPPackerIterationBuilds.ps1";
  "Invoke-HCPRestMethod.ps1"
)

foreach ($Module in $Modules) {
  Import-Module "./$Module" -Force
}
# --- Parse Webhook Payload
# 
# $WebhookJson = Get-Content .\sample.json -Raw | ConvertFrom-Json 

# $BucketSlug  = $WebhookJson.eventPayload.bucket.slug
# $IterationId = $WebhookJson.eventPayload.iteration.id
# $OrgId       = $WebhookJson.eventPayload.organization_id
# $ProjectId   = $WebhookJson.eventPayload.project_id

# --- Get Revoked Image Data
Write-Host -ForegroundColor Green -NoNewline "Connecting to HashiCorp Cloud Platform..."

$SecureClientSecret = ConvertTo-SecureString $ClientSecret -AsPlainText
Connect-HCP -ClientId $ClientId -ClientSecret $SecureClientSecret -OrgId $OrgId -ProjectId $ProjectId

Write-Host  -ForegroundColor Green "Finding revoked image name."

$VMName = Get-HCPPackerIterationBuilds -BucketSlug $BucketSlug -IterationId $IterationId | Select-Object -Expand Images | Select-Object -ExpandProperty ImageId
$VMId = Get-HCPPackerIterationBuilds -BucketSlug $BucketSlug -IterationId $IterationId | Select-Object -Expand Images | Select-Object -ExpandProperty Id

# --- Authenticate to vCenter and Delete VM
Write-Host -ForegroundColor Green "Deleting template $VMName..."
Connect-VIserver $vCenterServer -User $vCenterUsername -Password $vCenterPassword
$Template = Get-Template $VMName 
Write-Host $Template